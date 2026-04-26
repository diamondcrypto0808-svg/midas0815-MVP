module Api
  module V1
    class CommentsController < ApplicationController
      before_action :authenticate_user!, only: [:create]
      before_action :set_post

      # GET /api/v1/posts/:post_id/comments
      def index
        @comments = @post.comments
                         .includes(:user)
                         .recent
                         .page(params[:page] || 1)
                         .per(params[:per_page] || 20)

        render_success(
          @comments.map { |comment| comment_response(comment) },
          meta: pagination_meta(@comments)
        )
      end

      # POST /api/v1/posts/:post_id/comments
      def create
        @comment = @post.comments.build(comment_params.merge(user: current_user))

        if @comment.save
          # Notify post author
          if @post.user_id != current_user.id
            Notification.create!(
              user: @post.user,
              notification_type: 'new_comment',
              title: 'コメントがつきました',
              message: "#{current_user.profile&.display_name || current_user.email}さんがあなたの投稿にコメントしました",
              data: { post_id: @post.id, comment_id: @comment.id }
            )
          end

          render_success(comment_response(@comment), status: :created)
        else
          render_error(
            'コメントの投稿に失敗しました',
            code: 'COMMENT_CREATE_FAILED',
            status: :unprocessable_entity,
            details: @comment.errors.full_messages
          )
        end
      end

      private

      def set_post
        @post = Post.find(params[:post_id])
      end

      def comment_params
        params.require(:comment).permit(:content)
      end

      def comment_response(comment)
        {
          id: comment.id,
          content: comment.content,
          user: {
            id: comment.user.id,
            display_name: comment.user.profile&.display_name || comment.user.email,
            avatar_url: comment.user.profile&.avatar_url
          },
          created_at: comment.created_at
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
