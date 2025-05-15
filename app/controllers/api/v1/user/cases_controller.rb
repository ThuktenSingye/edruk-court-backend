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
            notify_defendant(@case)
            Users::Cases::CaseNotificationService.new(@case).notify_registrar(case_params[:court_id])
            sign_documents(@case) ? render_success : render_signing_failure
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

        def notify_defendant(court_case)
          defendant_attrs = case_params[:defendants_attributes]
          defendant = find_defendant(defendant_attrs[:cid_no])
          defendant_email = defendant_attrs[:email]

          if defendant
            assign_defendant_to_case(court_case, defendant)
            send_notification(defendant, court_case)
          else
            send_email_to_defendant(court_case.id, defendant_email, current_user.id)
          end
        end

        def find_defendant(cid_no)
          ::User.find_by(cid: cid_no)
        end

        def assign_defendant_to_case(court_case, defendant)
          defendant_role = Role.find_by(name: 'Defendant')
          return if court_case.case_participants.exists?(user_id: defendant.id, role_id: defendant_role.id)

          court_case.case_participants.create!(
            user_id: defendant.id,
            role_id: defendant_role.id
          )
        end

        def send_notification(defendant, court_case)
          CaseNotifier.new(notifications_params(court_case)).deliver(defendant)
        end

        def send_email_to_defendant(case_id, email, user_id)
          CaseMailer.new_case_email(case_id, email, user_id).deliver_later
        end

        def notifications_params(court_case)
          {
            record: court_case,
            message: 'New Case Notification',
            case: court_case
          }
        end

        def sign_documents(court_case)
          @signable_service = SignableSigningService.new(court_case, court_case.case_documents, current_user)
          @signable_service.sign_all
        end

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

        def render_success
          render_json :created, 'New Case Added Successfully', serialized_case(@case)
        end

        def render_signing_failure
          render_json :unprocessable_entity, 'Failed to sign all documents', @signable_service.errors
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
