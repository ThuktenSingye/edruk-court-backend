# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'
# rubocop:disable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup
RSpec.describe 'Api::V1::Case::CaseEvidences', type: :request do
  let(:court) { create(:court) }
  let(:general_user) { create(:user, confirmed_at: Time.zone.now) }
  let(:case_type) { create(:case_type, :civil) }
  let(:case_subtype) { create(:case_subtype, case_type: case_type) }
  let!(:court_case) { create(:case, case_subtype: case_subtype, case_type: case_type, court: court) }
  let!(:hearing_type) { create(:hearing_type) }
  let!(:hearing) { create(:hearing, case: court_case, hearing_type: hearing_type) }
  let!(:case_evidence) { create(:case_evidence, :with_image, hearing: hearing) }
  let(:registrar_user) { create(:user, :registrar, court: court, confirmed_at: Time.zone.now) }
  let(:judge_user) { create(:user, :judge, court: court, confirmed_at: Time.zone.now) }
  let(:clerk_user) { create(:user, :clerk, court: court, confirmed_at: Time.zone.now) }

  path '/api/v1/cases/:case_id/hearings/:hearing_id/evidences' do
    get 'List all case evidences for a given hearing' do
      tags 'Case Evidences'
      security [Bearer: []]
      produces 'application/json'

      parameter name: :case_id, in: :path, type: :integer, description: 'Case ID'
      parameter name: :hearing_id, in: :path, type: :integer, description: 'Hearing ID'

      context 'when role is clerk and hearing is post hearing' do
        subject(:get_evidences) do
          get api_v1_case_hearing_case_evidences_path(court_case, hearing)
          response
        end

        before { sign_in clerk_user }

        let!(:case_evidence) { create(:case_evidence, :with_image, hearing: hearing) }
        let!(:clerk_participant) do
          FactoryBot.create(:case_participant, case: court_case, user: clerk_user, role: Role.find_by(name: 'Clerk'))
        end

        response '200', 'Case Evidences found' do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     hearing_id: { type: :integer },
                     verified_by_judge: { type: :boolean },
                     verified_at: { type: :string, format: 'date-time' },
                     evidence_status: { type: :string },
                     evidence: {
                       type: :object,
                       properties: {
                         url: { type: :string },
                         filename: { type: :string },
                         content_type: { type: :string },
                         byte_size: { type: :integer }
                       }
                     }
                   },
                   required: %i[hearing_id evidence_status evidence]
                 }

          it { is_expected.to have_http_status :ok }
        end
      end
    end
  end

  path '/api/v1/cases/:case_id/hearings/:hearing_id/evidences' do
    post 'Create new case evidences record for a given hearing' do
      tags 'Case Evidences'
      security [Bearer: []]
      consumes 'multipart/form-data'
      produces 'application/json'

      parameter name: :case_id, in: :path, type: :integer, description: 'Case ID'
      parameter name: :hearing_id, in: :path, type: :integer, description: 'Hearing ID'
      parameter name: :evidence_params, in: :formData, schema: {
        type: :object,
        properties: {
          evidence_status: { type: :string },
          evidence: {
            type: :string,
            format: :binary,
            description: 'Document file to upload'
          }
        },
        required: [:evidence]
      }

      context 'when role is clerk and hearing is post hearing' do
        subject(:create_evidence) do
          post api_v1_case_hearing_case_evidences_path(court_case, hearing), params: { evidence: valid_evidence_params }
          response
        end

        before { sign_in clerk_user }

        let(:valid_evidence_params) do
          {
            hash_value: Faker::Lorem.sentence,
            evidence_status: :pending,
            evidence: Rack::Test::UploadedFile.new('spec/support/images/banner.jpg', 'image/jpg')
          }
        end
        let!(:clerk_participant) do
          FactoryBot.create(:case_participant, case: court_case, user: clerk_user, role: Role.find_by(name: 'Clerk'))
        end

        response '201', 'Case Evidence Created' do
          schema type: :object,
                 properties: {
                   id: { type: :integer },
                   hearing_id: { type: :integer },
                   verified_by_judge: { type: :boolean },
                   verified_at: { type: :string, format: 'date-time' },
                   evidence_status: { type: :string },
                   evidence: {
                     type: :object,
                     properties: {
                       url: { type: :string },
                       filename: { type: :string },
                       content_type: { type: :string },
                       byte_size: { type: :integer }
                     }
                   }
                 }
          it { is_expected.to have_http_status :created }
          it { expect { create_evidence }.to change(CaseEvidence, :count).by(1) }

          it 'attach the evidence' do
            create_evidence
            expect(CaseEvidence.last.evidence).to be_attached
          end

          it 'create evidence with correct status' do
            create_evidence
            expect(CaseEvidence.last.evidence_status).to eq(valid_evidence_params[:evidence_status].to_s)
          end
        end
      end
    end
  end

  path '/api/v1/cases/:case_id/hearings/:hearing_id/evidences/:id' do
    put 'Update the case evidence' do
      tags 'Case Evidences'
      security [Bearer: []]
      consumes 'multipart/form-data'
      produces 'application/json'

      parameter name: :case_id, in: :path, type: :integer, description: 'Case ID'
      parameter name: :hearing_id, in: :path, type: :integer, description: 'Hearing ID'
      parameter name: :evidence_params, in: :formData, schema: {
        type: :object,
        properties: {
          evidence_status: { type: :string },
          verified_by_judge: { type: :boolean },
          verified_at: { type: :datetime, format: 'date-time' }
        }
      }

      context 'when role is clerk and hearing is post hearing' do
        subject(:update_evidence) do
          put api_v1_case_hearing_case_evidence_path(court_case, hearing, case_evidence),
              params: { evidence: valid_evidence_params }
          response
        end

        before { sign_in clerk_user }

        let(:valid_evidence_params) do
          {
            evidence_status: :pending,
            verified_by_judge: false,
            verified_at: Time.zone.now
          }
        end
        let!(:case_evidence) { create(:case_evidence, :with_image, hearing: hearing) }
        let!(:clerk_participant) do
          FactoryBot.create(:case_participant, case: court_case, user: clerk_user, role: Role.find_by(name: 'Clerk'))
        end

        response '201', 'Case Documents Updated' do
          schema type: :object,
                 properties: {
                   id: { type: :integer },
                   hearing_id: { type: :integer },
                   evidence_status: { type: :string },
                   verified_by_judge: { type: :boolean },
                   verified_at: { type: :datetime, format: 'date-time' }
                 }

          it { is_expected.to have_http_status :ok }
          it { expect { update_evidence }.not_to change(CaseEvidence, :count) }

          it 'update evidence with correct status' do
            update_evidence
            expect(CaseEvidence.last.evidence_status).to eq(valid_evidence_params[:evidence_status].to_s)
          end
        end
      end
    end
  end

  # rubocop:enable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup
end
