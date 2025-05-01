# frozen_string_literal: true

# Base Controller
class ApplicationController < ActionController::API
  set_current_tenant_by_subdomain_or_domain(:court, :subdomain, :domain)

  include Pundit::Authorization
  include JsonResponse

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_bench_as_subtenant, if: :bench_present?
  after_action :verify_authorized, unless: :devise_controller?

  private

  def user_not_authorized
    render_json :unauthorized, 'You are not authorized to perform this action', nil
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
                                        :email, :password, :password_confirmation,
                                        {
                                          profile_attributes: %i[avatar first_name last_name cid_no phone_number gender]
                                        }
                                      ])
  end

  def bench_present?
    request.subdomains.size > 1
  end

  def set_bench_as_subtenant
    court_subdomain = request.subdomains.first
    bench_subdomain = request.subdomains.last

    @court = Court.find_by(subdomain: court_subdomain)
    @bench = @court.child_courts.find_by(subdomain: bench_subdomain)

    if @bench
      ActsAsTenant.current_tenant = @bench
      # set_current_tenant(@bench)
    else
      render json: { status: 404, message: 'Bench not found.' }, status: :not_found
    end
  end
end
