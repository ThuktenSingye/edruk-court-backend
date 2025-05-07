# frozen_string_literal: true

module Api
  module V1
    module Case
      # Case Document Controller Class
      class CaseDocumentsController < ApplicationController
        before_action :authenticate_user!
        before_action :court_cases
        before_action :case
        before_action :hearing
        before_action :case_document, except: %i[index create sign_all]
        before_action :case_documents, except: %i[index]

        def index
          @documents = policy_scope(@hearing.case_documents.order(created_at: :asc))
          authorize @documents
          render_json :ok, nil, serialized_case_documents(@documents)
        end

        def create
          @documents = @hearing.case_documents.build(case_document_params)
          authorize @documents
          if @documents.save
            render_json :created, 'Document added Successfully', serialized_case_document(@documents)
          else
            render_json :unprocessable_entity, 'Failed to add document', @documents.errors
          end
        end

        def update
          authorize @case_document
          if @case_document.update(case_document_params)
            render_json :ok, 'Document updated Successfully', serialized_case_document(@case_document)
          else
            render_json :unprocessable_entity, 'Failed to add document', @case_document.errors
          end
        end

        def sign
          authorize @case_document, :sign?, policy_class: CaseDocumentPolicy
          @signable_service = SignableSigningService.new(@case, @case_document, current_user)
          if @signable_service.sign_all
            render_json :ok, 'Signature added Successfully', nil
          else
            render_json :unprocessable_entity, 'Failed to sign document', @signable_service.errors.to_json
          end
        end

        def sign_all
          authorize @case_documents, :sign_all?, policy_class: CaseDocumentPolicy
          @signable_service = SignableSigningService.new(@case, @case_documents, current_user)
          if @signable_service.sign_all
            render_json :ok, 'Signature added Successfully', nil
          else
            render_json :unprocessable_entity, 'Failed to sign document', @signable_service.errors.json
          end
        end

        private

        def court_cases
          @court_cases ||= ::Case
                           .where(court_id: current_user.accessible_court_ids)
                           .or(::Case.where(bench_id: current_user.accessible_court_ids))
        end

        def case
          @case ||= @court_cases.find_by(id: params[:case_id])
        end

        def hearing
          @hearing ||= @case.hearings.find(params[:hearing_id])
        end

        def case_document
          @case_document ||= @hearing.case_documents.find(params[:id])
        end

        def case_documents
          @case_documents ||= policy_scope(@hearing.case_documents)
        end

        def serialized_case_documents(case_documents)
          case_documents.map do |document|
            CaseDocumentSerializer.new(document).serializable_hash[:data][:attributes]
          end
        end

        def serialized_case_document(case_document)
          CaseDocumentSerializer.new(case_document).serializable_hash[:data][:attributes]
        end

        def case_document_params
          params.expect(document: %i[document])
        end
      end
    end
  end
end
