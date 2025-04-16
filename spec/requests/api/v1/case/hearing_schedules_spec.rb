# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup
RSpec.describe 'Api::V1::Case::HearingSchedules', type: :request do
  let(:court) { FactoryBot.create(:court) }
  let(:general_user) { FactoryBot.create(:user, confirmed_at: Time.zone.now) }
  let(:case_type) { FactoryBot.create(:case_type, :civil) }
  let(:case_subtype) { FactoryBot.create(:case_subtype, case_type: case_type) }
  let!(:court_case) { FactoryBot.create(:case, case_subtype: case_subtype, case_type: case_type, court: court) }
  let!(:hearing_type) { FactoryBot.create(:hearing_type) }
  let!(:hearing) { FactoryBot.create(:hearing, case: court_case, hearing_type: hearing_type) }

  let(:registrar_user) { FactoryBot.create(:user, :registrar, court: court, confirmed_at: Time.zone.now) }
  let(:judge_user) { FactoryBot.create(:user, :judge, court: court, confirmed_at: Time.zone.now) }
  let(:clerk_user) { FactoryBot.create(:user, :clerk, court: court, confirmed_at: Time.zone.now) }

  path '/api/v1/cases/{case_id}/hearings/{hearing_id}/hearing_schedules' do
    get 'List all hearing schedules for a hearing' do
      tags 'Hearing Schedules'
      security [Bearer: []]
      produces 'application/json'

      parameter name: :case_id, in: :path, type: :integer, description: 'Case ID'
      parameter name: :hearing_id, in: :path, type: :integer, description: 'Hearing ID'

      context 'when role is judge' do
        before { sign_in judge_user }

        response '200', 'Hearing schedules found' do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     scheduled_date: { type: :string, format: 'date' },
                     schedule_status: { type: :string },
                     reschedule_reason: { type: :string },
                     scheduled_by_id: { type: :integer }
                   }
                 }
          it 'returns all hearing schedules for the hearing' do
            get api_v1_case_hearing_hearing_schedules_path(court_case, hearing)
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end

  path '/api/v1/hearing_schedules/today' do
    get 'List all hearing schedules for today ' do
      tags 'Hearing Schedules'
      security [Bearer: []]
      produces 'application/json'

      context 'when role is judge' do
        before { sign_in judge_user }

        response '200', 'Hearing schedules found' do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     scheduled_date: { type: :string, format: 'date' },
                     schedule_status: { type: :string },
                     reschedule_reason: { type: :string },
                     scheduled_by_id: { type: :integer },
                     case_title: { type: :string },
                     case_number: { type: :string },
                     hearing_status: { type: :string },
                     hearing_type: { type: :string }
                   }
                 }
          it 'returns all hearing schedules for the hearing today' do
            get today_api_v1_hearing_schedules_path
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end

  path '/api/v1/hearing_schedules/pending' do
    get 'List all pending hearing schedules' do
      tags 'Hearing Schedules'
      security [Bearer: []]
      produces 'application/json'

      context 'when role is judge' do
        before { sign_in judge_user }

        response '200', 'Hearing schedules found' do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     scheduled_date: { type: :string, format: 'date' },
                     schedule_status: { type: :string },
                     reschedule_reason: { type: :string },
                     scheduled_by_id: { type: :integer },
                     case_title: { type: :string },
                     case_number: { type: :string },
                     hearing_status: { type: :string },
                     hearing_type: { type: :string }
                   }
                 }
          it 'returns all pending hearing schedules' do
            get pending_api_v1_hearing_schedules_path
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end

  path '/api/v1/hearing_schedules/overdue' do
    get 'List all overdue hearing schedules' do
      tags 'Hearing Schedules'
      security [Bearer: []]
      produces 'application/json'

      context 'when role is judge' do
        before { sign_in judge_user }

        response '200', 'Hearing schedules found' do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     scheduled_date: { type: :string, format: 'date' },
                     schedule_status: { type: :string },
                     reschedule_reason: { type: :string },
                     scheduled_by_id: { type: :integer },
                     case_title: { type: :string },
                     case_number: { type: :string },
                     hearing_status: { type: :string },
                     hearing_type: { type: :string }
                   }
                 }
          it 'returns all overdue hearing schedules' do
            get overdue_api_v1_hearing_schedules_path
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end

  path '/api/v1/hearing_schedules/reminders' do
    get 'List all reminder hearing schedules' do
      tags 'Hearing Schedules'
      security [Bearer: []]
      produces 'application/json'

      context 'when role is judge' do
        subject(:get_reminder) do
          get reminders_api_v1_hearing_schedules_path
          response
        end

        before { sign_in judge_user }

        let!(:hearing_schedule) { create(:hearing_schedule, hearing: hearing, scheduled_by: judge_user) }

        response '200', 'Hearing schedules found' do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     scheduled_date: { type: :string, format: 'date' },
                     schedule_status: { type: :string },
                     reschedule_reason: { type: :string },
                     scheduled_by_id: { type: :integer },
                     case_title: { type: :string },
                     case_number: { type: :string },
                     hearing_status: { type: :string },
                     hearing_type: { type: :string }
                   }
                 }
          it { is_expected.to have_http_status :ok }
        end
      end
    end

    get 'List reminders on hearing schedules if user is not court official' do
      tags 'Hearing Schedules'
      security [Bearer: []]
      produces 'application/json'

      context 'when role is general user, it return empty array' do
        before { sign_in general_user }

        response '200', 'Hearing schedules found' do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {}
                 }
          it 'returns all hearing schedules for the hearing today' do
            get reminders_api_v1_hearing_schedules_path
            expect(api_response['data']).to eq([])
          end
        end
      end
    end
  end

  path '/api/v1/cases/{case_id}/hearings/{hearing_id}/hearing_schedules/{id}' do
    parameter name: :case_id, in: :path, type: :integer, description: 'Case ID'
    parameter name: :hearing_id, in: :path, type: :integer, description: 'Hearing ID'
    parameter name: :id, in: :path, type: :integer, description: 'Hearing Schedule ID'

    put 'Update a hearing schedule' do
      tags 'Hearing Schedules'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :hearing_schedule_params, in: :body, schema: {
        type: :object,
        properties: {
          scheduled_date: { type: :string, format: 'date' },
          schedule_status: { type: :string },
          reschedule_reason: { type: :string }
        }
      }

      context 'when role is clerk and hearing is preliminary' do
        subject(:update_hearing_schedule) do
          put api_v1_case_hearing_hearing_schedule_path(court_case, preliminary_hearing, hearing_schedule),
              params: { hearing_schedule: valid_params }
          response
        end

        let(:valid_params) do
          {
            scheduled_date: Faker::Date.forward(days: 2),
            schedule_status: 'approved',
            reschedule_reason: Faker::Lorem.paragraph
          }
        end

        let!(:preliminary_hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
        let!(:preliminary_hearing) do
          FactoryBot.create(:hearing, case: court_case, hearing_type: preliminary_hearing_type)
        end
        let!(:clerk_participant) do
          FactoryBot.create(:case_participant, case: court_case, user: clerk_user, role: Role.find_by(name: 'Clerk'))
        end

        let!(:judge_participant) do
          FactoryBot.create(:case_participant, case: court_case, user: judge_user, role: Role.find_by(name: 'Judge'))
        end

        let!(:hearing_schedule) do
          FactoryBot.create(:hearing_schedule, hearing: preliminary_hearing, scheduled_by: clerk_user)
        end

        before { sign_in judge_user }

        response '200', 'Hearing schedule updated' do
          schema type: :object,
                 properties: {
                   scheduled_date: { type: :string, format: 'date' },
                   schedule_status: { type: :string },
                   reschedule_reason: { type: :string },
                   scheduled_by_id: { type: :integer }
                 }

          it { is_expected.to have_http_status :ok }
          it { expect { update_hearing_schedule }.to change(Noticed::Notification, :count).by(1) }

          # rubocop:disable RSpec/MultipleExpectations
          it 'send notification' do
            update_hearing_schedule
            notification = Noticed::Notification.last
            expect(notification.recipient).to eq(clerk_participant.user)
            expect(notification.params[:message]).to eq('schedule_update')
          end
          # rubocop:enable RSpec/MultipleExpectations
        end
      end

      context 'when role is judge but requested hearing schedule changes' do
        subject(:update_hearing_schedule) do
          put api_v1_case_hearing_hearing_schedule_path(court_case, preliminary_hearing, hearing_schedule),
              params: { hearing_schedule: valid_params }
          response
        end

        let(:valid_params) do
          {
            scheduled_date: Faker::Date.forward(days: 2),
            schedule_status: 'changes_requested',
            reschedule_reason: Faker::Lorem.paragraph
          }
        end

        let!(:preliminary_hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
        let!(:preliminary_hearing) do
          FactoryBot.create(:hearing, case: court_case, hearing_type: preliminary_hearing_type)
        end
        let!(:clerk_participant) do
          FactoryBot.create(:case_participant, case: court_case, user: clerk_user, role: Role.find_by(name: 'Clerk'))
        end

        let!(:judge_participant) do
          FactoryBot.create(:case_participant, case: court_case, user: judge_user, role: Role.find_by(name: 'Judge'))
        end

        let!(:hearing_schedule) do
          FactoryBot.create(:hearing_schedule, hearing: preliminary_hearing, scheduled_by: clerk_user)
        end

        before { sign_in judge_user }

        response '200', 'Hearing schedule updated' do
          schema type: :object,
                 properties: {
                   scheduled_date: { type: :string, format: 'date' },
                   schedule_status: { type: :string },
                   reschedule_reason: { type: :string },
                   scheduled_by_id: { type: :integer }
                 }
          it { is_expected.to have_http_status :ok }
          it { expect { update_hearing_schedule }.to change(Noticed::Notification, :count).by(1) }

          # rubocop:disable RSpec/MultipleExpectations
          it 'send notification' do
            update_hearing_schedule
            notification = Noticed::Notification.last
            expect(notification.recipient).to eq(clerk_participant.user)
            expect(notification.params[:message]).to eq('schedule_update')
          end
          # rubocop:enable RSpec/MultipleExpectations
        end
      end

      context 'when role is registrar and hearing is miscellaneous' do
        subject(:update_hearing_schedule) do
          put api_v1_case_hearing_hearing_schedule_path(court_case, miscellaneous_hearing, hearing_schedule),
              params: { hearing_schedule: valid_params }
          response
        end

        let(:valid_params) do
          {
            scheduled_date: Faker::Date.forward(days: 2),
            schedule_status: 'rescheduled',
            reschedule_reason: Faker::Lorem.paragraph
          }
        end

        let!(:miscellaneous_hearing_type) { FactoryBot.create(:hearing_type, :miscellaneous) }
        let!(:miscellaneous_hearing) do
          FactoryBot.create(:hearing, case: court_case, hearing_type: miscellaneous_hearing_type)
        end
        let!(:hearing_schedule) do
          FactoryBot.create(:hearing_schedule, hearing: miscellaneous_hearing, scheduled_by: registrar_user)
        end

        let!(:judge_participant) do
          FactoryBot.create(:case_participant, case: court_case, user: judge_user, role: Role.find_by(name: 'Judge'))
        end

        before { sign_in registrar_user }

        response '200', 'Hearing schedule updated' do
          schema type: :object,
                 properties: {
                   scheduled_date: { type: :string, format: 'date' },
                   schedule_status: { type: :string },
                   reschedule_reason: { type: :string },
                   scheduled_by_id: { type: :integer }
                 }
          it { is_expected.to have_http_status :ok }
          it { expect { update_hearing_schedule }.to change(Noticed::Notification, :count).by(1) }

          # rubocop:disable RSpec/MultipleExpectations
          it 'send notification' do
            update_hearing_schedule
            notification = Noticed::Notification.last
            expect(notification.recipient).to eq(judge_participant.user)
            expect(notification.params[:message]).to eq('schedule_update')
          end
          # rubocop:enable RSpec/MultipleExpectations
        end
      end

      context 'when unauthorized' do
        let!(:preliminary_hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
        let!(:preliminary_hearing) do
          FactoryBot.create(:hearing, case: court_case, hearing_type: preliminary_hearing_type)
        end
        let!(:hearing_schedule) do
          FactoryBot.create(:hearing_schedule, hearing: preliminary_hearing, scheduled_by: clerk_user)
        end

        before { sign_in registrar_user }

        response '401', 'Unauthorized' do
          let(:valid_params) do
            {
              scheduled_date: Faker::Date.forward(days: 2),
              schedule_status: 'pending',
              reschedule_reason: Faker::Lorem.paragraph
            }
          end

          it 'returns unauthorized' do
            put api_v1_case_hearing_hearing_schedule_path(court_case, preliminary_hearing, hearing_schedule),
                params: { hearing_schedule: valid_params }
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end
    end

    delete 'Delete a hearing schedule' do
      tags 'Hearing Schedules'
      security [Bearer: []]
      produces 'application/json'

      context 'when role is clerk and hearing is preliminary' do
        subject(:cancel_hearing_schedule) do
          delete api_v1_case_hearing_hearing_schedule_path(court_case, preliminary_hearing, hearing_schedule)
          response
        end

        let!(:preliminary_hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
        let!(:preliminary_hearing) do
          FactoryBot.create(:hearing, case: court_case, hearing_type: preliminary_hearing_type)
        end
        let!(:case_participant) do
          FactoryBot.create(:case_participant, case: court_case, user: clerk_user, role: Role.find_by(name: 'Clerk'))
        end
        let!(:hearing_schedule) do
          FactoryBot.create(:hearing_schedule, hearing: preliminary_hearing, scheduled_by: clerk_user)
        end

        before { sign_in clerk_user }

        response '200', 'Hearing schedule deleted' do
          it { is_expected.to have_http_status :ok }
        end
      end

      context 'when unauthorized' do
        let!(:preliminary_hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
        let!(:preliminary_hearing) do
          FactoryBot.create(:hearing, case: court_case, hearing_type: preliminary_hearing_type)
        end
        let!(:hearing_schedule) do
          FactoryBot.create(:hearing_schedule, hearing: preliminary_hearing, scheduled_by: clerk_user)
        end

        before { sign_in judge_user }

        response '401', 'Unauthorized' do
          it 'returns unauthorized' do
            delete api_v1_case_hearing_hearing_schedule_path(court_case, preliminary_hearing, hearing_schedule)
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup
