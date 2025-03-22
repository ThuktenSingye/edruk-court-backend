# frozen_string_literal: true

# Base Controller
class ApplicationController < ActionController::API
  set_current_tenant_by_subdomain_or_domain(:court, :subdomain, :domain)
  include Pundit::Authorization

  before_action :set_bench_as_subtenant, if: :bench_present?

  private

  def bench_present?
    request.path.include?('benches')
  end

  def set_bench_as_subtenant
    bench_name = request.path.split('/').last
    @bench = current_tenant.child_courts.find_by(name: bench_name)
    if @bench
      set_current_tenant(@bench)
    else
      render json: { status: 404, message: 'Bench not found.' }, status: :not_found
    end
  end
end
