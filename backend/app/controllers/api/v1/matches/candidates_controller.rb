module Api
  module V1
    module Matches
      class CandidatesController < ApplicationController
        before_action :authenticate_user!

        # GET /api/v1/matches/candidates
        def index
          # Get all users except current user and already matched users
          matched_user_ids = current_user.matches.pluck(:user1_id, :user2_id).flatten.uniq
          excluded_ids = [current_user.id] + matched_user_ids

          candidates = User.where.not(id: excluded_ids)
                          .includes(:profile)
                          .limit(params[:limit] || 20)

          # Calculate similarity scores
          candidates_with_scores = candidates.map do |candidate|
            similarity = Matching::SimilarityCalculator.new(
              current_user.profile,
              candidate.profile
            ).calculate

            {
              user: candidate,
              similarity_score: similarity
            }
          end

          # Sort by similarity score (descending)
          sorted_candidates = candidates_with_scores.sort_by { |c| -c[:similarity_score] }

          render_success(
            sorted_candidates.map { |c| candidate_response(c[:user], c[:similarity_score]) }
          )
        end

        private

        def candidate_response(user, similarity_score)
          {
            id: user.id,
            display_name: user.profile&.display_name || user.email,
            avatar_url: user.profile&.avatar_url,
            bio: user.profile&.bio,
            interests: user.profile&.interests_list || [],
            skills: user.profile&.skills_list || [],
            similarity_score: similarity_score
          }
        end
      end
    end
  end
end
