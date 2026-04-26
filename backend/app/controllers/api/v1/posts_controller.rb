module Api
  module V1
    class PostsController < ApplicationController
      before_action :authenticate_user!, except: [:index, :show]
      before_action :set_post, only: [:show, :destroy, :like, :unlike]

      # GET /api/v1/posts
      def index
        @posts = Post.includes(:user, :comments, :likes)
                     .recent
                     .page(params[:page] || 1)
                     .per(params[:per_page] || 20)

        render_success(
          @posts.map { |post| post_response(post) },
          meta: pagination_meta(@posts)
        )
      end

      # POST /api/v1/posts
      def create
        @post = current_user.posts.build(post_params)

        if @post.save
          # Track analytics event
          AnalyticsEvent.create!(
            user: current_user,
            event_type: 'post_created',
            event_category: 'sns',
            properties: { post_id: @post.id }
          )

          render_success(post_response(@post), status: :created)
        else
          render_error(
            '投稿の作成に失敗しました',
            code: 'POST_CREATE_FAILED',
            status: :unprocessable_entity,
            details: @post.errors.full_messages
          )
        end
      end

      # GET /api/v1/posts/:id
      def show
        render_success(post_response(@post))
      end

      # DELETE /api/v1/posts/:id
      def destroy
        authorize @post

        if @post.destroy
          render_success({ message: '投稿を削除しました' })
        else
          render_error(
            '投稿の削除に失敗しました',
            code: 'POST_DELETE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # POST /api/v1/posts/:id/like
      def like
        like = @post.likes.build(user: current_user)

        if like.save
          render_success({
            message: 'いいねしました',
            likes_count: @post.reload.likes_count
          })
        else
          render_error(
            'いいねに失敗しました',
            code: 'LIKE_FAILED',
            status: :unprocessable_entity,
            details: like.errors.full_messages
          )
        end
      end

      # DELETE /api/v1/posts/:id/like
      def unlike
        like = @post.likes.find_by(user: current_user)

        if like&.destroy
          render_success({
            message: 'いいねを取り消しました',
            likes_count: @post.reload.likes_count
          })
        else
          render_error(
            'いいねの取り消しに失敗しました',
            code: 'UNLIKE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      private

      def set_post
        @post = Post.find(params[:id])
      end

      def post_params
        params.require(:post).permit(:content)
      end

      def post_response(post)
        {
          id: post.id,
          content: post.content,
          likes_count: post.likes_count,
          comments_count: post.comments_count,
          liked_by_current_user: current_user ? post.liked_by?(current_user) : false,
          user: {
            id: post.user.id,
            display_name: post.user.profile&.display_name || post.user.email,
            avatar_url: post.user.profile&.avatar_url
          },
          created_at: post.created_at,
          updated_at: post.updated_at
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
