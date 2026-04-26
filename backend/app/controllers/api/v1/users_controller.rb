module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!
      before_action :set_user, only: [:show, :update, :profile, :update_profile, :upload_avatar]

      # GET /api/v1/users/:id
      def show
        authorize @user
        render_success(user_response(@user))
      end

      # PUT /api/v1/users/:id
      def update
        authorize @user

        if @user.update(user_update_params)
          render_success(user_response(@user))
        else
          render_error(
            'ユーザー情報の更新に失敗しました',
            code: 'UPDATE_FAILED',
            status: :unprocessable_entity,
            details: @user.errors.full_messages
          )
        end
      end

      # GET /api/v1/users/:id/profile
      def profile
        authorize @user
        render_success(profile_response(@user.profile))
      end

      # PUT /api/v1/users/:id/profile
      def update_profile
        authorize @user

        if @user.profile.update(profile_params)
          render_success(profile_response(@user.profile))
        else
          render_error(
            'プロフィールの更新に失敗しました',
            code: 'PROFILE_UPDATE_FAILED',
            status: :unprocessable_entity,
            details: @user.profile.errors.full_messages
          )
        end
      end

      # POST /api/v1/users/:id/avatar
      def upload_avatar
        authorize @user

        if params[:avatar].present?
          @user.profile.avatar.attach(params[:avatar])
          render_success({
            message: 'アバター画像をアップロードしました',
            avatar_url: @user.profile.avatar_url
          })
        else
          render_error(
            'アバター画像が指定されていません',
            code: 'AVATAR_REQUIRED',
            status: :bad_request
          )
        end
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def authenticate_user!
        token = request.headers['Authorization']&.split(' ')&.last
        @current_user = Authentication::TokenService.verify_token(token) if token

        unless @current_user
          render_error(
            '認証が必要です',
            code: 'UNAUTHORIZED',
            status: :unauthorized
          )
        end
      end

      def current_user
        @current_user
      end

      def user_update_params
        params.require(:user).permit(:email)
      end

      def profile_params
        params.require(:profile).permit(
          :display_name,
          :bio,
          interests: [],
          skills: [],
          preferences: {}
        )
      end

      def user_response(user)
        {
          id: user.id,
          email: user.email,
          created_at: user.created_at,
          profile: profile_response(user.profile)
        }
      end

      def profile_response(profile)
        {
          id: profile.id,
          display_name: profile.display_name,
          bio: profile.bio,
          avatar_url: profile.avatar_url,
          interests: profile.interests_list,
          skills: profile.skills_list,
          preferences: profile.preferences_hash
        }
      end
    end
  end
end
