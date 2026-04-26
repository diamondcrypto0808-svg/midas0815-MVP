module Api
  module V1
    class NotificationsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_notification, only: [:mark_as_read]

      # GET /api/v1/notifications
      def index
        @notifications = current_user.notifications
                                     .order(created_at: :desc)
                                     .page(params[:page] || 1)
                                     .per(params[:per_page] || 20)

        unread_count = current_user.notifications.unread.count

        render_success(
          @notifications.map { |notification| notification_response(notification) },
          meta: pagination_meta(@notifications).merge(unread_count: unread_count)
        )
      end

      # PUT /api/v1/notifications/:id/read
      def mark_as_read
        if @notification.mark_as_read!
          render_success({
            message: '通知を既読にしました',
            notification: notification_response(@notification)
          })
        else
          render_error(
            '通知の更新に失敗しました',
            code: 'NOTIFICATION_UPDATE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # PUT /api/v1/notifications/settings
      def update_settings
        # Store notification settings in user profile preferences
        settings = params.require(:settings).permit(
          :email_notifications,
          :push_notifications,
          :match_notifications,
          :comment_notifications,
          :like_notifications
        )

        current_user.profile.update(
          preferences: current_user.profile.preferences_hash.merge(
            notification_settings: settings.to_h
          )
        )

        render_success({
          message: '通知設定を更新しました',
          settings: current_user.profile.preferences_hash[:notification_settings]
        })
      end

      private

      def set_notification
        @notification = current_user.notifications.find(params[:id])
      end

      def notification_response(notification)
        {
          id: notification.id,
          type: notification.notification_type,
          title: notification.title,
          message: notification.message,
          data: notification.data,
          read: notification.read,
          read_at: notification.read_at,
          created_at: notification.created_at
        }
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count,
          per_page: collection.limit_value
        }
      end
    end
  end
end
