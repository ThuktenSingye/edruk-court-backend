# frozen_string_literal: true

module Api
  module V1
    module Case
      # Case Controller
      class CasesController < ApplicationController
        before_action :authenticate_user!
        before_action :court_cases
        before_action :case, only: %i[show update files]
        before_action :case_service, only: :statistics

        def index
          @court_cases = policy_scope(@court_cases)
          authorize @court_cases
          @cases = @court_cases.order(created_at: :desc).includes(:case_participants)
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
          authorize :case, :statistics?
          render_json :ok, nil, @case_service.case_statistics
        end

        def files
          authorize :case, :files?
          @files = CaseQuery.new(@case).call(current_user)
          render_json :ok, nil, @files
        end

        private

        def court_cases
          @court_cases ||= ::Case
                           .where(court_id: current_user.accessible_court_ids)
                           .or(::Case.where(bench_id: current_user.accessible_court_ids))
        end

        def case
          @case ||= @court_cases.find_by(id: params[:id])
        end

        def case_service
          @case_service ||= Cases::CaseService.new(@court_cases)
        end

        def serialized_cases(court_cases)
          court_cases.map { |c| CaseSerializer.new(c).serializable_hash[:data][:attributes] }
        end

        def serialized_case(court_case)
          CaseSerializer.new(court_case).serializable_hash[:data][:attributes]
        end

        # rubocop:disable Rails/StrongParametersExpect
        def case_params
          params.require(:case).permit(
            :case_number, :registration_number, :judgement_number, :title, :summary, :case_priority, :case_status,
            { case_documents_attributes: %i[id document_status document hash_value] }
          )
        end
        # rubocop:enable Rails/StrongParametersExpect
      end
    end
  end
end
