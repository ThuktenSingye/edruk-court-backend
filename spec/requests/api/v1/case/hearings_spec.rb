# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup, Style/GlobalVars
RSpec.describe 'Api::V1::Case::Hearings', type: :request do
  let!(:bench) { Court.find_by(court_type: 'bench') }
  let(:user) { FactoryBot.create(:user, confirmed_at: Time.zone.now) }
  let(:case_type) { FactoryBot.create(:case_type) }
  let(:case_subtype) { FactoryBot.create(:case_subtype, case_type: case_type) }
  let!(:court_case) { FactoryBot.create(:case, case_subtype: case_subtype, court: $default_account) }
  let!(:hearing_type) { FactoryBot.create(:hearing_type) }
  let!(:miscellaneous_hearing_type) { FactoryBot.create(:hearing_type, :miscellaneous) }
  let!(:hearing) { FactoryBot.create(:hearing, case: court_case, hearing_type: hearing_type) }
  let!(:miscellaneous_hearing) do
    FactoryBot.create(:hearing, case: court_case, hearing_type: miscellaneous_hearing_type)
  end
  let!(:preliminary_hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
  let!(:preliminary_hearing) do
    FactoryBot.create(:hearing, case: court_case, hearing_type: preliminary_hearing_type)
  end

  let(:registrar_user) { FactoryBot.create(:user, :registrar, confirmed_at: Time.zone.now) }
  let!(:judge_user) { FactoryBot.create(:user, :judge, confirmed_at: Time.zone.now) }
  let!(:clerk_user) { FactoryBot.create(:user, :clerk, confirmed_at: Time.zone.now) }

  path '/api/v1/cases/{case_id}/hearings' do
    get 'List all hearings for a case' do
      tags 'Hearings'
      security [Bearer: []]
      produces 'application/json'

      parameter name: :case_id, in: :path, type: :integer, description: 'Case ID'

      context 'when role is judge' do
        before { sign_in judge_user }

        response '200', 'Hearings found' do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     hearing_status: { type: :string },
                     hearing_type_id: { type: :integer }
                   }
                 }

          it 'returns all hearings for the case' do
            get api_v1_case_hearings_path(court_case)
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end

  path '/api/v1/cases/{case_id}/hearings/{hearing_id}' do
    parameter name: :case_id, in: :path, type: :integer, description: 'Case ID'
    parameter name: :hearing_id, in: :path, type: :integer, description: 'Hearing ID'

    put 'Update a hearing' do
      tags 'Hearings'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :hearing_params, in: :body, schema: {
        type: :object,
        properties: {
          id: { type: :integer },
          hearing_status: { type: :string },
          hearing_type_id: { type: :integer }
        }
      }

      context 'when role is clerk and hearing is not miscellaneous' do
        subject(:update_hearing) do
          put api_v1_case_hearing_path(court_case, hearing), params: { hearing: valid_hearing_params }
          response
        end

        let(:valid_hearing_params) do
          {
            hearing_status: :completed,
            hearing_type_id: hearing_type.id
          }
        end
        let!(:clerk_participant) do
          FactoryBot.create(:case_participant, case: court_case, user: clerk_user,
                                               role: Role.find_by(name: 'Clerk'))
        end
        let!(:judge_participant) do
          FactoryBot.create(:case_participant, case: court_case, user: judge_user,
                                               role: Role.find_by(name: 'Judge'))
        end

        before { sign_in clerk_user }

        response '200', 'Hearing updated' do
          schema type: :object,
                 properties: {
                   id: { type: :integer },
                   hearing_status: { type: :string },
                   hearing_type_id: { type: :integer }
                 }
          it { is_expected.to have_http_status :ok }
          it { expect { update_hearing }.to change(Noticed::Notification, :count).by(1) }

          it 'updates the hearing status to ongoing' do
            update_hearing
            expect(api_response['data']['hearing_status']).to eq(valid_hearing_params[:hearing_status].to_s)
          end

          it 'send pre-hearing notification to judge' do
            update_hearing
            notification = Noticed::Notification.last
            expect(notification.recipient).to eq(judge_participant.user)
          end
        end
      end

      context 'when role is clerk and hearing is miscellaneous' do
        let(:valid_hearing_params) do
          {
            hearing_status: :completed,
            hearing_type_id: hearing_type.id
          }
        end

        before { sign_in clerk_user }

        response '401', 'Unauthorized' do
          it 'does not update the hearing' do
            put api_v1_case_hearing_path(court_case, miscellaneous_hearing), params: { hearing: valid_hearing_params }
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      context 'when role is general user' do
        let(:valid_hearing_params) do
          {
            hearing_status: :completed
          }
        end

        before { sign_in user }

        response '401', 'Unauthorized' do
          it 'does not update the hearing' do
            put api_v1_case_hearing_path(court_case, hearing), params: { hearing: valid_hearing_params }
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end
    end
  end

  path '/api/v1/cases/{case_id}/hearings' do
    post 'Create a hearing' do
      tags 'Hearings'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :hearing_params, in: :body, schema: {
        type: :object,
        properties: {
          id: { type: :integer },
          hearing_status: { type: :string },
          hearing_type_id: { type: :integer },
          case_id: { type: :integer },
          bench_id: { type: :integer },
          judge_id: { type: :integer },
          hearing_schedules_attributes: {
            type: :array,
            items: {
              type: :object,
              properties: {
                scheduled_date: { type: :string, format: 'date' },
                schedule_status: { type: :string },
                reschedule_reason: { type: :string },
                scheduled_by_id: { type: :integer }
              }
            }
          }
        }
      }

      # context 'when role is judge and hearing is miscellaneous' do
      #   let(:valid_hearing_params) do
      #     {
      #       hearing_status: :completed,
      #       hearing_type_id: miscellaneous_hearing_type.id
      #     }
      #   end
      #
      #   before { sign_in judge_user }
      #
      #   response '401', 'Unauthorized' do
      #     it 'does not allow the creation of a miscellaneous hearing' do
      #       post api_v1_case_hearings_path(court_case), params: { hearing: valid_hearing_params }
      #       expect(response).to have_http_status(:unauthorized)
      #     end
      #   end
      # end

      context 'when role is registrar and hearing is preliminary' do
        subject(:create_hearing) do
          post api_v1_case_hearings_path(court_case), params: { hearing: valid_hearing_params }
          response
        end

        let(:valid_hearing_params) do
          {
            hearing_status: :ongoing,
            hearing_type_id: preliminary_hearing_type.id,
            case_id: court_case.id,
            judge_id: judge_user.id,
            bench_id: bench.id,
            clerk_id: clerk_user.id,
            hearing_schedules_attributes: [
              {
                scheduled_date: Faker::Date.backward(days: 14),
                schedule_status: :pending,
                reschedule_reason: Faker::Lorem.paragraph,
                scheduled_by_id: registrar_user.id
              }
            ]
          }
        end

        before { sign_in registrar_user }

        response '201', 'Hearing created' do
          schema type: :object,
                 properties: {
                   id: { type: :integer },
                   hearing_status: { type: :string },
                   hearing_type_id: { type: :integer },
                   case_id: { type: :integer },
                   judge_id: { type: :integer },
                   bench_id: { type: :integer },
                   clerk_id: { type: :integer },
                   hearing_schedules_attributes: {
                     type: :array,
                     items: {
                       type: :object,
                       properties: {
                         scheduled_date: { type: :string, format: 'date' },
                         schedule_status: { type: :string },
                         reschedule_reason: { type: :string },
                         scheduled_by_id: { type: :integer }
                       }
                     }
                   }
                 }

          it { is_expected.to have_http_status :created }
        end
      end

      context 'when role is registrar and hearing is miscellaneous' do
        subject(:create_hearing) do
          post api_v1_case_hearings_path(court_case), params: { hearing: valid_hearing_params }
          response
        end

        let(:valid_hearing_params) do
          {
            hearing_status: :ongoing,
            hearing_type_id: miscellaneous_hearing_type.id,
            case_id: court_case.id,
            judge_id: nil,
            bench_id: nil,
            clerk_id: nil,
            hearing_schedules_attributes: [
              {
                scheduled_date: Faker::Date.backward(days: 14),
                schedule_status: :pending,
                reschedule_reason: Faker::Lorem.paragraph,
                scheduled_by_id: registrar_user.id
              }
            ]
          }
        end

        before { sign_in registrar_user }

        response '201', 'Hearing created' do
          schema type: :object,
                 properties: {
                   id: { type: :integer },
                   hearing_status: { type: :string },
                   hearing_type_id: { type: :integer },
                   case_id: { type: :integer },
                   judge_id: { type: :integer },
                   bench_id: { type: :integer },
                   clerk_id: { type: :integer },
                   hearing_schedules_attributes: {
                     type: :array,
                     items: {
                       type: :object,
                       properties: {
                         scheduled_date: { type: :string, format: 'date' },
                         schedule_status: { type: :string },
                         reschedule_reason: { type: :string },
                         scheduled_by_id: { type: :integer }
                       }
                     }
                   }
                 }
          it { is_expected.to have_http_status :created }
          it { expect { create_hearing }.to change(Hearing, :count).by(1) }
        end
      end

      context 'when role is clerk and hearing is post hearing' do
        subject(:create_hearing) do
          post api_v1_case_hearings_path(court_case), params: { hearing: valid_hearing_params }
          response
        end

        let(:valid_hearing_params) do
          {
            hearing_status: :ongoing,
            hearing_type_id: hearing_type.id,
            case_id: court_case.id,
            hearing_schedules_attributes: [
              {
                scheduled_date: Faker::Date.backward(days: 14),
                schedule_status: :pending,
                reschedule_reason: Faker::Lorem.paragraph,
                scheduled_by_id: registrar_user.id
              }
            ]
          }
        end

        let!(:judge_participant) do
          create(:case_participant, case: court_case, user: judge_user,
                                    role: Role.find_by(name: 'Judge'))
        end
        let!(:clerk_participant) do
          create(:case_participant, case: court_case, user: clerk_user,
                                    role: Role.find_by(name: 'Clerk'))
        end

        before { sign_in clerk_user }

        response '201', 'Hearing created' do
          schema type: :object,
                 properties: {
                   id: { type: :integer },
                   hearing_status: { type: :string },
                   hearing_type_id: { type: :integer },
                   case_id: { type: :integer },
                   judge_id: { type: :integer },
                   bench_id: { type: :integer },
                   clerk_id: { type: :integer },
                   hearing_schedules_attributes: {
                     type: :array,
                     items: {
                       type: :object,
                       properties: {
                         scheduled_date: { type: :string, format: 'date' },
                         schedule_status: { type: :string },
                         reschedule_reason: { type: :string },
                         scheduled_by_id: { type: :integer }
                       }
                     }
                   }
                 }
          it { is_expected.to have_http_status :created }
          it { expect { create_hearing }.to change(Hearing, :count).by(1) }
          it { expect { create_hearing }.to change(Noticed::Notification, :count).by(1) }

          it 'send pre-hearing notification to judge' do
            create_hearing
            notification = Noticed::Notification.last
            expect(notification.recipient).to eq(judge_user)
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup, Style/GlobalVars
