# frozen_string_literal: true

# Base Controller
class ApplicationController < ActionController::API
  set_current_tenant_through_filter

  include Pundit::Authorization
  include JsonResponse

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :set_tenant
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_bench_as_subtenant, if: :bench_present?
  after_action :verify_authorized, unless: :devise_controller?

  private

  def user_not_authorized
    render_json :unauthorized, 'You are not authorized to perform this action', nil
  end

  def configure_permitted_parameters
    if params[:user] && params[:user][:role] == 'Organization'
      devise_parameter_sanitizer.permit(:sign_up, keys: [
        :email, :password, :password_confirmation, :role,
        {
          profile_attributes: %i[avatar first_name phone_number]
        }
      ])

    else
      devise_parameter_sanitizer.permit(:sign_up, keys: [
        :email, :password, :password_confirmation, :role,
        {
          profile_attributes: %i[avatar first_name last_name cid_no phone_number gender]
        }
      ])
    end

  end

  def set_tenant
    host = request.host
    if /\A\d{1,3}(\.\d{1,3}){3}\z/.match?(host) # matches IP addresses
      ActsAsTenant.current_tenant = nil
    else
      tenant = Court.find_by(subdomain: host.split('.').first)
      ActsAsTenant.current_tenant = tenant
    end
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
