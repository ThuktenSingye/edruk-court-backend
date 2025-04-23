# frozen_string_literal: true

module Api
  module V1
    # Benches Controller
    class BenchesController < ApplicationController
      before_action :authenticate_user!
      before_action :benches

      def index
        authorize Court, :index?, policy_class: BenchPolicy
        @bench_list = policy_scope(
          @benches,
          policy_scope_class: BenchPolicy::Scope
        )

        render_json :ok, nil, serialized_benches_with_stats(@bench_list)
      end

      private

      def statistics(cases)
        {
          total: total_cases(cases),
          civil: count_by_case_type(cases, 'Civil'),
          criminal: count_by_case_type(cases, 'Criminal'),
          others: count_by_case_type(cases, 'Other'),
          active: count_by_status(cases, :active),
          decided: count_by_status(cases, :decided),
          appeal: count_appeals(cases)
        }
      end

      def benches
        @benches ||= current_tenant.child_courts.where(court_type: :bench)
      end

      def serialized_benches_with_stats(benches)
        benches.map do |bench|
          serialized = BenchSerializer.new(bench).serializable_hash[:data][:attributes]
          serialized.merge(statistics: calculate_bench_statistics(bench))
        end
      end

      def calculate_bench_statistics(bench)
        cases = bench.cases
        { total: total_cases(cases),
          civil: count_by_case_type(cases, 'Civil'),
          criminal: count_by_case_type(cases, 'Criminal'),
          others: count_by_case_type(cases, 'Other'),
          active: count_by_case_type(cases, :active),
          decided: count_by_case_type(cases, :decided),
          pending: count_by_case_type(cases, :pending),
          appeals: count_appeals(cases) }
      end

      def total_cases(cases)
        cases.count
      end

      def count_by_case_type(cases, type)
        cases.joins(:case_type).where(case_types: { title: type }).count
      end

      def count_by_status(cases, status)
        cases.where(case_status: status).count
      end

      def count_appeals(cases)
        cases.where(is_appeal: true).count
      end

      def serialized_benches(benches)
        benches.map { |bench| BenchSerializer.new(bench).serializable_hash[:data][:attributes] }
      end
    end
  end
end
