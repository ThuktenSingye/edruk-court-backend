# frozen_string_literal: true

# Json Response Concern
module JsonResponse
  extend ActiveSupport::Concern

  private

  def render_json(status, message, data = nil)
    render json: {
      status: status,
      message: message,
      data: data
    }, status: status_code(status)
  end

  def status_code(status)
    case status
    when :ok then 200
    when :created then 201
    when :unprocessable_entity then 422
    when :not_found then 404
    else 500
    end
  end
end
