# frozen_string_literal: true

module Api
  module V1
    module User
      # Cases Controller for users (Plaintiff, Defendant, Lawyer)
      class CasesController < ApplicationController
        before_action :authenticate_user!
        before_action :cases
        before_action :case, only: %i[show update files]

        def index
          authorize policy_scope(@cases)
          @cases = @cases.order(created_at: :desc).includes(:case_participants)
          render_json :ok, nil, serialized_cases(@cases)
        end

        def show
          authorize @case
          render_json :ok, nil, serialized_case(@case)
        end

        def create
          @case = Users::Cases::CaseService.new(case_params, current_user).build_case
          authorize @case
          if @case.save
            Users::Cases::CaseNotificationService.new(@case).notify_registrar(case_params[:court_id])
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

        def files
          authorize :case, :files?
          @files = CaseQuery.new(@case).call(current_user)
          render_json :ok, nil, @files
        end

        def active
          authorize :case, :active?
          @active_case = policy_scope(@cases.where(case_status: 'active').order(created_at: :asc))
          render_json :ok, nil, serialized_cases(@active_case)
        end

        private

        def cases
          role_ids = Role.where(name: %w[Plaintiff Defendant]).pluck(:id)
          @cases ||= ::Case.joins(:case_participants).where(
            case_participants: {
              user_id: current_user.id,
              role_id: role_ids
            }
          ).distinct
        end

        def case
          @case ||= @cases.find_by(id: params[:id])
        end

        def serialized_cases(court_cases)
          court_cases.map { |c| CaseSerializer.new(c).serializable_hash[:data][:attributes] }
        end

        def serialized_case(court_case)
          CaseSerializer.new(court_case).serializable_hash[:data][:attributes]
        end

        # rubocop:disable Rails/StrongParametersExpect, Metrics/MethodLength
        def case_params
          params.require(:case).permit(
            :case_number, :registration_number, :judgement_number, :title, :summary, :case_priority, :case_status,
            :court_id,
            {
              case_documents_attributes: %i[id document_status document hash_value],
              defendants_attributes: [:id, :first_name, :last_name, :email, :cid_no, :phone_number,
                                      {
                                        addresses_attributes: %i[
                                          id dzongkhag gewog street_address address_type _destroy
                                        ]
                                      }]
            }
          )
        end
        # rubocop:enable Rails/StrongParametersExpect, Metrics/MethodLength
      end
    end
  end
end
