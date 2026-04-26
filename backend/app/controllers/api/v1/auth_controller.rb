module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :verify_authenticity_token

      # POST /api/v1/auth/register
      def register
        user = User.new(user_params)
        
        if user.save
          # Send confirmation email (if confirmable is enabled)
          user.send_confirmation_instructions if user.respond_to?(:send_confirmation_instructions)
          
          render_success(
            { 
              user: user_response(user),
              message: '登録が完了しました。確認メールを送信しました。' 
            },
            status: :created
          )
        else
          render_error(
            '登録に失敗しました',
            code: 'REGISTRATION_FAILED',
            status: :unprocessable_entity,
            details: user.errors.full_messages
          )
        end
      end

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: params[:email])

        if user&.valid_password?(params[:password])
          if user.confirmed?
            # Generate tokens
            tokens = Authentication::TokenService.generate_tokens(user)
            
            # Track sign in
            user.update(
              sign_in_count: user.sign_in_count + 1,
              current_sign_in_at: Time.current,
              last_sign_in_at: user.current_sign_in_at,
              current_sign_in_ip: request.remote_ip,
              last_sign_in_ip: user.current_sign_in_ip
            )

            render_success({
              user: user_response(user),
              access_token: tokens[:access_token],
              refresh_token: tokens[:refresh_token]
            })
          else
            render_error(
              'メールアドレスが確認されていません',
              code: 'EMAIL_NOT_CONFIRMED',
              status: :unauthorized
            )
          end
        else
          render_error(
            'メールアドレスまたはパスワードが正しくありません',
            code: 'INVALID_CREDENTIALS',
            status: :unauthorized
          )
        end
      end

      # POST /api/v1/auth/logout
      def logout
        # Invalidate refresh token
        if params[:refresh_token]
          Authentication::TokenService.revoke_token(params[:refresh_token])
        end

        render_success({ message: 'ログアウトしました' })
      end

      # POST /api/v1/auth/refresh
      def refresh
        refresh_token = params[:refresh_token]
        
        if refresh_token.blank?
          return render_error(
            'リフレッシュトークンが必要です',
            code: 'REFRESH_TOKEN_REQUIRED',
            status: :bad_request
          )
        end

        user = Authentication::TokenService.verify_token(refresh_token, type: 'refresh')
        
        if user
          tokens = Authentication::TokenService.generate_tokens(user)
          render_success({
            access_token: tokens[:access_token],
            refresh_token: tokens[:refresh_token]
          })
        else
          render_error(
            'リフレッシュトークンが無効です',
            code: 'INVALID_REFRESH_TOKEN',
            status: :unauthorized
          )
        end
      end

      # POST /api/v1/auth/password/reset
      def request_password_reset
        user = User.find_by(email: params[:email])
        
        if user
          user.send_reset_password_instructions
          render_success({ 
            message: 'パスワードリセット用のメールを送信しました' 
          })
        else
          # Don't reveal if email exists
          render_success({ 
            message: 'パスワードリセット用のメールを送信しました' 
          })
        end
      end

      # PUT /api/v1/auth/password
      def reset_password
        user = User.reset_password_by_token(
          reset_password_token: params[:reset_password_token],
          password: params[:password],
          password_confirmation: params[:password_confirmation]
        )

        if user.errors.empty?
          render_success({ 
            message: 'パスワードをリセットしました' 
          })
        else
          render_error(
            'パスワードのリセットに失敗しました',
            code: 'PASSWORD_RESET_FAILED',
            status: :unprocessable_entity,
            details: user.errors.full_messages
          )
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end

      def user_response(user)
        {
          id: user.id,
          email: user.email,
          confirmed: user.confirmed?,
          created_at: user.created_at
        }
      end
    end
  end
end
