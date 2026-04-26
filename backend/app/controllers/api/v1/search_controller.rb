module Api
  module V1
    class SearchController < ApplicationController
      # GET /api/v1/search
      def index
        query = params[:q]

        if query.blank?
          return render_error(
            '検索クエリが必要です',
            code: 'QUERY_REQUIRED',
            status: :bad_request
          )
        end

        results = {
          users: search_users(query),
          posts: search_posts(query),
          contents: search_contents(query)
        }

        render_success(results)
      end

      # GET /api/v1/search/users
      def users
        query = params[:q]

        if query.blank?
          return render_error(
            '検索クエリが必要です',
            code: 'QUERY_REQUIRED',
            status: :bad_request
          )
        end

        users = search_users(query, limit: params[:limit] || 20)
        render_success(users)
      end

      # GET /api/v1/search/posts
      def posts
        query = params[:q]

        if query.blank?
          return render_error(
            '検索クエリが必要です',
            code: 'QUERY_REQUIRED',
            status: :bad_request
          )
        end

        posts = search_posts(query, limit: params[:limit] || 20)
        render_success(posts)
      end

      # GET /api/v1/search/contents
      def contents
        query = params[:q]

        if query.blank?
          return render_error(
            '検索クエリが必要です',
            code: 'QUERY_REQUIRED',
            status: :bad_request
          )
        end

        contents = search_contents(query, limit: params[:limit] || 20)
        render_success(contents)
      end

      private

      def search_users(query, limit: 5)
        User.joins(:profile)
            .where("profiles.display_name ILIKE ? OR users.email ILIKE ?", "%#{query}%", "%#{query}%")
            .limit(limit)
            .map { |user|
              {
                id: user.id,
                type: 'user',
                display_name: user.profile&.display_name || user.email,
                email: user.email,
                avatar_url: user.profile&.avatar_url,
                bio: user.profile&.bio
              }
            }
      end

      def search_posts(query, limit: 5)
        Post.where("content ILIKE ?", "%#{query}%")
            .includes(:user)
            .order(created_at: :desc)
            .limit(limit)
            .map { |post|
              {
                id: post.id,
                type: 'post',
                content: post.content.truncate(200),
                user: {
                  id: post.user.id,
                  display_name: post.user.profile&.display_name || post.user.email
                },
                likes_count: post.likes_count,
                comments_count: post.comments_count,
                created_at: post.created_at
              }
            }
      end

      def search_contents(query, limit: 5)
        contents = Content.published
                          .where("title ILIKE ? OR body ILIKE ?", "%#{query}%", "%#{query}%")
                          .includes(:author)
                          .order(published_at: :desc)
                          .limit(limit)

        contents.map { |content|
          {
            id: content.id,
            type: 'content',
            title: content.title,
            body: content.body.truncate(200),
            slug: content.slug,
            author: {
              id: content.author.id,
              display_name: content.author.profile&.display_name || content.author.email
            },
            published_at: content.published_at
          }
        }
      end
    end
  end
end
