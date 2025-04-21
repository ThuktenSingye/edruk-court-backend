# frozen_string_literal: true

module Api
  module V1
    # Benches Controller
    class BenchesController < ApplicationController
      before_action :authenticate_user!

      def index
        authorize Court, :index?, policy_class: BenchPolicy
        @benches = policy_scope(
          current_tenant.child_courts.where(court_type: :bench),
          policy_scope_class: BenchPolicy::Scope
        )
        render_json :ok, nil, serialized_benches(@benches)
      end

      private

      def serialized_benches(benches)
        benches.map { |bench| BenchSerializer.new(bench).serializable_hash[:data][:attributes] }
      end
    end
  end
end
