# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers, RSpec/ExampleLength
RSpec.describe 'Api::V1::Cases', type: :request do
  let(:court) { create(:court) }
  let!(:user) { create(:user, :court_user, court: court, confirmed_at: Time.zone.now) }
  let(:case_type) { create(:case_type, :civil) }
  let(:case_subtype) { create(:case_subtype, case_type: case_type) }
  let!(:court_case) { create(:case, case_subtype: case_subtype, case_type: case_type, court: court) }
  let(:case_params) do
    {
      case_number: Faker::Number.number(digits: 2).to_s,
      registration_number: Faker::Number.number(digits: 2).to_s,
      judgement_number: Faker::Number.number(digits: 2).to_s,
      title: Faker::Lorem.word,
      summary: Faker::Lorem.sentence,
      case_priority: :low,
      case_status: :filed,
      case_subtype: case_subtype,
      court: court
    }
  end

  path '/api/v1/cases' do
    get 'List all cases' do
      tags 'Cases'
      security [Bearer: []]
      produces 'application/json'

      context 'when role is registrar' do
        let(:registrar_user) { create(:user, :registrar, court: court, confirmed_at: Time.zone.now) }

        before { sign_in registrar_user }

        response '200', 'Cases found' do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     case_number: { type: :string },
                     registration_number: { type: :string },
                     judgement_number: { type: :string },
                     title: { type: :string },
                     summary: { type: :string },
                     case_priority: { type: :string },
                     case_status: { type: :string },
                     case_subtype: { type: :integer },
                     court: { type: :integer }
                   }
                 }

          it 'returns all cases' do
            get api_v1_cases_path
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end

  path '/api/v1/cases/{case_id}' do
    parameter name: :case_id, in: :path, type: :integer, description: 'Case ID'

    get 'Show a case' do
      tags 'Cases'
      security [Bearer: []]
      produces 'application/json'

      context 'when case record exists' do
        before { sign_in user }

        response '200', 'Case found' do
          it 'returns the case details' do
            get api_v1_case_path(court_case)
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end

  path '/api/v1/cases' do
    post 'Create a case' do
      tags 'Cases'
      security [Bearer: []]
      consumes 'application/json'
      parameter name: :case_params, in: :body, schema: {
        type: :object,
        properties: {
          case_number: { type: :string },
          registration_number: { type: :string },
          judgement_number: { type: :string },
          title: { type: :string },
          summary: { type: :string },
          case_priority: { type: :string },
          case_status: { type: :string },
          case_subtype: { type: :integer },
          court: { type: :integer }
        }
      }
      context 'when role is not registrar' do
        subject(:create_case) do
          post api_v1_cases_path, params: { case: case_params }
          response
        end

        let(:clerk_user) { create(:user, :clerk, confirmed_at: Time.zone.now) }

        before { sign_in clerk_user }

        response '401', 'Unauthorized' do
          it { is_expected.to have_http_status(:unauthorized) }
          it { expect { create_case }.not_to change(Case, :count) }
        end
      end

      produces 'application/json'
      context 'when role is registrar' do
        subject(:create_case) do
          post api_v1_cases_path, params: { case: case_params }
          response
        end

        let(:registrar_user) { create(:user, :registrar, confirmed_at: Time.zone.now) }

        before { sign_in registrar_user }

        response '201', 'Case created' do
          schema type: :object,
                 properties: {
                   id: { type: :integer },
                   case_number: { type: :string },
                   registration_number: { type: :string },
                   judgement_number: { type: :string },
                   title: { type: :string },
                   summary: { type: :string },
                   case_priority: { type: :string },
                   case_status: { type: :string },
                   case_subtype: { type: :integer },
                   court: { type: :integer }
                 }
          it { is_expected.to have_http_status(:created) }
          it { expect { create_case }.to change(Case, :count).by(1) }
        end
      end
    end
  end

  path '/api/v1/cases/{case_id}' do
    parameter name: :case_id, in: :path, type: :integer, description: 'Case ID'

    put 'Update a case' do
      tags 'Cases'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :case_params, in: :body, schema: {
        type: :object,
        properties: {
          id: { type: :integer },
          case_number: { type: :string },
          registration_number: { type: :string },
          judgement_number: { type: :string },
          title: { type: :string },
          summary: { type: :string },
          case_priority: { type: :string },
          case_status: { type: :string }
        }
      }

      context 'when role is judge' do
        let(:judge_user) { create(:user, :judge, confirmed_at: Time.zone.now) }

        before { sign_in judge_user }

        response '401', 'Unauthorized' do
          it 'does not update the case' do
            put api_v1_case_path(court_case), params: { case: case_params }
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      context 'when role is registrar' do
        subject(:update_case) do
          put api_v1_case_path(court_case), params: { case: case_params }
          response
        end

        let(:registrar_user) { create(:user, :registrar, confirmed_at: Time.zone.now) }

        before { sign_in registrar_user }

        response '200', 'Case updated' do
          schema type: :object,
                 properties: {
                   id: { type: :integer },
                   case_number: { type: :string },
                   registration_number: { type: :string },
                   judgement_number: { type: :string },
                   title: { type: :string },
                   summary: { type: :string },
                   case_priority: { type: :string },
                   case_status: { type: :string },
                   case_subtype: { type: :integer },
                   court: { type: :integer }
                 }
          it { is_expected.to have_http_status :ok }

          it 'updates the case details' do
            update_case
            expect(Case.last).to have_attributes(
              case_number: case_params[:case_number],
              registration_number: case_params[:registration_number],
              judgement_number: case_params[:judgement_number],
              title: case_params[:title],
              summary: case_params[:summary],
              case_priority: case_params[:case_priority].to_s,
              case_status: case_params[:case_status].to_s
            )
          end
        end
      end
    end
  end

  path '/api/v1/cases/statistics' do
    get 'Get case statistics' do
      tags 'Cases'
      security [Bearer: []]
      produces 'application/json'

      context 'when user is not court official' do
        let(:general_user) { create(:user, confirmed_at: Time.zone.now) }

        before { sign_in general_user }

        response '401', 'Unauthorized' do
          it 'returns unauthorized' do
            get statistics_api_v1_cases_path
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      context 'when user is court official' do
        let(:registrar_user) { create(:user, :registrar, confirmed_at: Time.zone.now) }

        before { sign_in registrar_user }

        response '200', 'Statistics found' do
          schema type: :object,
                 properties: {
                   total: { type: :integer },
                   civil: { type: :integer },
                   criminal: { type: :integer },
                   others: { type: :integer },
                   active: { type: :integer },
                   decided: { type: :integer },
                   appeal: { type: :integer }
                 }

          it 'returns case statistics' do
            get statistics_api_v1_cases_path
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers, RSpec/ExampleLength
