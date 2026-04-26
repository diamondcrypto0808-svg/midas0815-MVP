class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Pundit::Authorization

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation])
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :password, :password_confirmation, :current_password])
  end

  def handle_not_found(exception)
    render json: {
      success: false,
      error: {
        code: 'NOT_FOUND',
        message: 'リソースが見つかりません',
        details: exception.message
      }
    }, status: :not_found
  end

  def handle_validation_error(exception)
    render json: {
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: '入力内容に誤りがあります',
        details: exception.record.errors.full_messages.map { |msg| { message: msg } }
      }
    }, status: :unprocessable_entity
  end

  def handle_parameter_missing(exception)
    render json: {
      success: false,
      error: {
        code: 'PARAMETER_MISSING',
        message: "必須パラメータが不足しています: #{exception.param}",
        param: exception.param
      }
    }, status: :bad_request
  end

  def handle_unauthorized(exception)
    render json: {
      success: false,
      error: {
        code: 'FORBIDDEN',
        message: 'この操作を実行する権限がありません'
      }
    }, status: :forbidden
  end

  def render_success(data, status: :ok, meta: {})
    render json: {
      success: true,
      data: data,
      meta: meta
    }, status: status
  end

  def render_error(message, code: 'ERROR', status: :bad_request, details: nil)
    error_response = {
      success: false,
      error: {
        code: code,
        message: message
      }
    }
    error_response[:error][:details] = details if details
    render json: error_response, status: status
  end
end
