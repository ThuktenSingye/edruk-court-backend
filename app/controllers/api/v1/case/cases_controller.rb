# frozen_string_literal: true

module Api
  module V1
    module Case
      # Case Controller
      class CasesController < ApplicationController
        before_action :authenticate_user!
        before_action :case, only: %i[show update]
        before_action :court_case, only: :statistics

        def index
          @cases = current_tenant.cases.all
          @cases = policy_scope(@cases)
          @cases = @cases.order(created_at: :desc).includes(:case_participants)
          render_json :ok, nil, serialized_cases(@cases)
        end

        def show
          authorize @case
          render_json :ok, nil, serialized_case(@case)
        end

        def create
          @case = current_tenant.cases.build(case_params)
          authorize @case
          if @case.save
            @case.update(case_status: :filed)
            render_json :created, 'New Cases Added Successfully', serialized_case(@case)
          else
            render_json :unprocessable_entity, 'Failed to Add Case', @case.errors
          end
        end

        def update
          authorize @case
          if @case.update(case_params)
            render_json :ok, 'Case Updated Successfully', serialized_case(@case)
          else
            render_json :unprocessable_entity, 'Failed to Update Case', @case.errors
          end
        end

        def statistics
          authorize @court_case
          stats_data = {
            total: @court_case.count,
            active: @court_case.where(case_status: :active).count,
            decided: @court_case.where(case_status: :decided).count,
            appeal: @court_case.where(is_appeal: true).count
          }
          render_json :ok, nil, stats_data
        end

        private

        def case
          @case ||= current_tenant.cases.find(params[:id])
        end

        def court_case
          @court_case = current_tenant.cases
        end

        def serialized_cases(court_cases)
          court_cases.map { |c| CaseSerializer.new(c).serializable_hash[:data][:attributes] }
        end

        def serialized_case(court_case)
          CaseSerializer.new(court_case).serializable_hash[:data][:attributes]
        end

        def case_params
          params.expect(case: %i[case_number registration_number judgement_number title summary case_priority
                                 case_status])
        end
      end
    end
  end
end
