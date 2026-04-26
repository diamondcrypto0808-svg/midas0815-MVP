module Api
  module V1
    class MatchesController < ApplicationController
      before_action :authenticate_user!

      # GET /api/v1/matches
      def index
        @matches = current_user.matches
                               .includes(:user1, :user2)
                               .order(matched_at: :desc)
                               .page(params[:page] || 1)
                               .per(params[:per_page] || 20)

        render_success(
          @matches.map { |match| match_response(match) },
          meta: pagination_meta(@matches)
        )
      end

      private

      def match_response(match)
        other_user = match.other_user(current_user)

        {
          id: match.id,
          similarity_score: match.similarity_score,
          matched_at: match.matched_at,
          user: {
            id: other_user.id,
            display_name: other_user.profile&.display_name || other_user.email,
            avatar_url: other_user.profile&.avatar_url,
            bio: other_user.profile&.bio,
            interests: other_user.profile&.interests_list || [],
            skills: other_user.profile&.skills_list || []
          }
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
