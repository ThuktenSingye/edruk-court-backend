# frozen_string_literal: true

module Api
  module V1
    module Case
      # Case Evidence Controller
      class CaseEvidencesController < ApplicationController
        before_action :authenticate_user!
        before_action :case
        before_action :hearing
        before_action :case_evidence, only: [:update]

        def index
          @case_evidences = policy_scope(@hearing.case_evidences.order(created_at: :asc))
          authorize @case_evidences
          render_json :ok, nil, serialized_case_evidences(@case_evidences)
        end

        def create
          @case_evidence = @hearing.case_evidences.build(evidence_params)
          authorize @case_evidence
          if @case_evidence.save
            render_json :created, 'Evidence added Successfully', serialized_case_evidence(@case_evidence)
          else
            render_json :unprocessable_entity, 'Failed to add evidence', @case_evidence.errors
          end
        end

        def update
          authorize @case_evidence
          if @case_evidence.update(evidence_params)
            render_json :ok, 'Evidence updated Successfully', serialized_case_evidence(@case_evidence)
          else
            render_json :unprocessable_entity, 'Failed to add evidence', @case_evidence.errors
          end
        end

        private

        def case
          @case ||= current_tenant.cases.find(params[:case_id])
        end

        def hearing
          @hearing ||= @case.hearings.find(params[:hearing_id])
        end

        def case_evidence
          @case_evidence ||= @hearing.case_evidences.find(params[:id])
        end

        def serialized_case_evidences(case_evidences)
          case_evidences.map do |case_evidence|
            CaseEvidenceSerializer.new(case_evidence).serializable_hash[:data][:attributes]
          end
        end

        def serialized_case_evidence(case_evidence)
          CaseEvidenceSerializer.new(case_evidence).serializable_hash[:data][:attributes]
        end

        def evidence_params
          params.expect(evidence: %i[evidence hash_value evidence_status verified_by_judge verified_at])
        end
      end
    end
  end
end
