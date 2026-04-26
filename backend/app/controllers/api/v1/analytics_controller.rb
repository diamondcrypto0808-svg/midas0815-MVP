module Api
  module V1
    class AnalyticsController < ApplicationController
      before_action :authenticate_user!
      before_action :require_admin!, except: [:events]

      # GET /api/v1/analytics/dashboard
      def dashboard
        date_range = parse_date_range

        render_success({
          users: {
            total: User.count,
            new_today: User.where('created_at >= ?', Date.today).count,
            new_this_week: User.where('created_at >= ?', 1.week.ago).count,
            new_this_month: User.where('created_at >= ?', 1.month.ago).count
          },
          posts: {
            total: Post.count,
            today: Post.where('created_at >= ?', Date.today).count,
            this_week: Post.where('created_at >= ?', 1.week.ago).count,
            this_month: Post.where('created_at >= ?', 1.month.ago).count
          },
          matches: {
            total: Match.count,
            today: Match.where('matched_at >= ?', Date.today).count,
            this_week: Match.where('matched_at >= ?', 1.week.ago).count,
            this_month: Match.where('matched_at >= ?', 1.month.ago).count
          },
          contents: {
            total: Content.count,
            published: Content.published.count,
            draft: Content.draft.count
          },
          top_events: top_events(date_range),
          user_activity: user_activity_chart(date_range)
        })
      end

      # GET /api/v1/analytics/events
      def events
        @events = if current_user.admin?
                    AnalyticsEvent.all
                  else
                    current_user.analytics_events
                  end

        @events = @events.order(created_at: :desc)
                         .page(params[:page] || 1)
                         .per(params[:per_page] || 50)

        render_success(
          @events.map { |event| event_response(event) },
          meta: pagination_meta(@events)
        )
      end

      # POST /api/v1/analytics/events
      def create_event
        @event = AnalyticsEvent.new(event_params.merge(user: current_user))

        if @event.save
          render_success(event_response(@event), status: :created)
        else
          render_error(
            'イベントの記録に失敗しました',
            code: 'EVENT_CREATE_FAILED',
            status: :unprocessable_entity,
            details: @event.errors.full_messages
          )
        end
      end

      # GET /api/v1/analytics/reports
      def reports
        date_range = parse_date_range
        report_type = params[:type] || 'summary'

        case report_type
        when 'summary'
          render_success(summary_report(date_range))
        when 'user_engagement'
          render_success(user_engagement_report(date_range))
        when 'content_performance'
          render_success(content_performance_report(date_range))
        else
          render_error(
            '不明なレポートタイプです',
            code: 'INVALID_REPORT_TYPE',
            status: :bad_request
          )
        end
      end

      private

      def require_admin!
        unless current_user.admin?
          render_error(
            '管理者権限が必要です',
            code: 'ADMIN_REQUIRED',
            status: :forbidden
          )
        end
      end

      def parse_date_range
        start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago
        end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today
        start_date..end_date
      end

      def top_events(date_range)
        AnalyticsEvent.where(created_at: date_range)
                      .group(:event_type)
                      .count
                      .sort_by { |_, count| -count }
                      .first(10)
                      .map { |type, count| { event_type: type, count: count } }
      end

      def user_activity_chart(date_range)
        AnalyticsEvent.where(created_at: date_range)
                      .group_by_day(:created_at)
                      .count
                      .map { |date, count| { date: date, count: count } }
      end

      def summary_report(date_range)
        {
          period: { start: date_range.first, end: date_range.last },
          total_events: AnalyticsEvent.where(created_at: date_range).count,
          unique_users: AnalyticsEvent.where(created_at: date_range).distinct.count(:user_id),
          events_by_category: AnalyticsEvent.where(created_at: date_range)
                                            .group(:event_category)
                                            .count,
          daily_breakdown: user_activity_chart(date_range)
        }
      end

      def user_engagement_report(date_range)
        {
          period: { start: date_range.first, end: date_range.last },
          active_users: User.joins(:analytics_events)
                           .where(analytics_events: { created_at: date_range })
                           .distinct
                           .count,
          posts_created: Post.where(created_at: date_range).count,
          comments_created: Comment.where(created_at: date_range).count,
          likes_given: Like.where(created_at: date_range).count,
          matches_made: Match.where(matched_at: date_range).count
        }
      end

      def content_performance_report(date_range)
        contents = Content.published.where(published_at: date_range)

        {
          period: { start: date_range.first, end: date_range.last },
          total_published: contents.count,
          top_contents: contents.limit(10).map { |c|
            {
              id: c.id,
              title: c.title,
              views: c.analytics_events.where(event_type: 'content_view').count
            }
          }
        }
      end

      def event_params
        params.require(:event).permit(:event_type, :event_category, properties: {})
      end

      def event_response(event)
        {
          id: event.id,
          event_type: event.event_type,
          event_category: event.event_category,
          properties: event.properties,
          user_id: event.user_id,
          created_at: event.created_at
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
