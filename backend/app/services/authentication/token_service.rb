module Authentication
  class TokenService
    SECRET_KEY = Rails.application.credentials.secret_key_base || 'development_secret_key'

    class << self
      def generate_tokens(user)
        access_token = generate_access_token(user)
        refresh_token = generate_refresh_token(user)

        # Store refresh token in Redis
        store_refresh_token(user.id, refresh_token)

        {
          access_token: access_token,
          refresh_token: refresh_token
        }
      end

      def verify_token(token, type: 'access')
        payload = decode_token(token)
        return nil unless payload
        return nil unless payload['type'] == type

        # For refresh tokens, verify it exists in Redis
        if type == 'refresh'
          return nil unless refresh_token_valid?(payload['user_id'], token)
        end

        User.find_by(id: payload['user_id'])
      rescue JWT::DecodeError, JWT::ExpiredSignature
        nil
      end

      def revoke_token(refresh_token)
        payload = decode_token(refresh_token)
        return false unless payload

        redis_key = refresh_token_key(payload['user_id'], refresh_token)
        Redis.current.del(redis_key)
        true
      rescue
        false
      end

      private

      def generate_access_token(user)
        payload = {
          user_id: user.id,
          email: user.email,
          exp: 15.minutes.from_now.to_i,
          type: 'access'
        }
        JWT.encode(payload, SECRET_KEY, 'HS256')
      end

      def generate_refresh_token(user)
        payload = {
          user_id: user.id,
          exp: 7.days.from_now.to_i,
          type: 'refresh',
          jti: SecureRandom.uuid
        }
        JWT.encode(payload, SECRET_KEY, 'HS256')
      end

      def decode_token(token)
        JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' }).first
      rescue JWT::DecodeError, JWT::ExpiredSignature
        nil
      end

      def store_refresh_token(user_id, token)
        redis_key = refresh_token_key(user_id, token)
        Redis.current.setex(redis_key, 7.days.to_i, true)
      end

      def refresh_token_valid?(user_id, token)
        redis_key = refresh_token_key(user_id, token)
        Redis.current.exists?(redis_key)
      end

      def refresh_token_key(user_id, token)
        "refresh_token:#{user_id}:#{Digest::SHA256.hexdigest(token)}"
      end
    end
  end
end
