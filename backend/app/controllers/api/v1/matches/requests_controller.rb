module Api
  module V1
    module Matches
      class RequestsController < ApplicationController
        before_action :authenticate_user!
        before_action :set_match_request, only: [:update]

        # GET /api/v1/matches/requests
        def index
          @sent_requests = current_user.sent_match_requests
                                       .includes(:receiver)
                                       .order(created_at: :desc)

          @received_requests = current_user.received_match_requests
                                           .includes(:sender)
                                           .order(created_at: :desc)

          render_success({
            sent: @sent_requests.map { |req| request_response(req, :sent) },
            received: @received_requests.map { |req| request_response(req, :received) }
          })
        end

        # POST /api/v1/matches/requests
        def create
          receiver = User.find(params[:receiver_id])

          @match_request = current_user.sent_match_requests.build(
            receiver: receiver,
            message: params[:message]
          )

          if @match_request.save
            render_success(
              request_response(@match_request, :sent),
              status: :created
            )
          else
            render_error(
              'マッチングリクエストの送信に失敗しました',
              code: 'MATCH_REQUEST_FAILED',
              status: :unprocessable_entity,
              details: @match_request.errors.full_messages
            )
          end
        end

        # PUT /api/v1/matches/requests/:id
        def update
          authorize @match_request

          status = params[:status]

          unless ['accepted', 'rejected'].include?(status)
            return render_error(
              'ステータスはacceptedまたはrejectedである必要があります',
              code: 'INVALID_STATUS',
              status: :bad_request
            )
          end

          if @match_request.update(status: status)
            message = status == 'accepted' ? 'リクエストを承認しました' : 'リクエストを拒否しました'
            render_success({
              message: message,
              request: request_response(@match_request, :received)
            })
          else
            render_error(
              'リクエストの更新に失敗しました',
              code: 'REQUEST_UPDATE_FAILED',
              status: :unprocessable_entity,
              details: @match_request.errors.full_messages
            )
          end
        end

        private

        def set_match_request
          @match_request = MatchRequest.find(params[:id])
        end

        def request_response(request, type)
          other_user = type == :sent ? request.receiver : request.sender

          {
            id: request.id,
            status: request.status,
            message: request.message,
            user: {
              id: other_user.id,
              display_name: other_user.profile&.display_name || other_user.email,
              avatar_url: other_user.profile&.avatar_url,
              bio: other_user.profile&.bio
            },
            created_at: request.created_at,
            updated_at: request.updated_at
          }
        end
      end
    end
  end
end
