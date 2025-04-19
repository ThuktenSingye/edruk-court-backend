# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup
RSpec.describe 'Api::V1::Case::CaseDocuments', type: :request do
  let(:court) { create(:court) }
  let(:general_user) { create(:user, confirmed_at: Time.zone.now) }
  let(:case_type) { create(:case_type, :civil) }
  let(:case_subtype) { create(:case_subtype, case_type: case_type) }
  let!(:court_case) { create(:case, case_subtype: case_subtype, case_type: case_type, court: court) }
  let!(:hearing_type) { create(:hearing_type) }
  let!(:hearing) { create(:hearing, case: court_case, hearing_type: hearing_type) }
  let!(:case_document) { create(:case_document, :with_document, hearing: hearing) }
  let(:registrar_user) { create(:user, :registrar, court: court, confirmed_at: Time.zone.now) }
  let(:judge_user) { create(:user, :judge, court: court, confirmed_at: Time.zone.now) }
  let(:clerk_user) { create(:user, :clerk, court: court, confirmed_at: Time.zone.now) }

  path '/api/v1/cases/:case_id/hearings/:hearing_id/documents' do
    get 'List all case documents for a given hearing' do
      tags 'Case Documents'
      security [Bearer: []]
      produces 'application/json'

      parameter name: :case_id, in: :path, type: :integer, description: 'Case ID'
      parameter name: :hearing_id, in: :path, type: :integer, description: 'Hearing ID'

      context 'when role is clerk and hearing is post hearing' do
        subject(:get_hearing_document) do
          get api_v1_case_hearing_case_documents_path(court_case, hearing)
          response
        end

        before { sign_in clerk_user }

        let!(:case_document) { create(:case_document, :with_document, hearing: hearing) }
        let!(:clerk_participant) do
          FactoryBot.create(:case_participant, case: court_case, user: clerk_user, role: Role.find_by(name: 'Clerk'))
        end

        response '200', 'Case Documents found' do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     hearing_id: { type: :integer },
                     verified_by_judge: { type: :boolean },
                     verified_at: { type: :string, format: 'date-time' },
                     document_status: { type: :string },
                     document: {
                       type: :object,
                       properties: {
                         url: { type: :string },
                         filename: { type: :string },
                         content_type: { type: :string },
                         byte_size: { type: :integer }
                       }
                     }
                   },
                   required: %i[hearing_id document_status document]
                 }

          it { is_expected.to have_http_status :ok }
        end
      end
    end
  end

  path '/api/v1/cases/:case_id/hearings/:hearing_id/documents' do
    post 'Create new case documents record for a given hearing' do
      tags 'Case Documents'
      security [Bearer: []]
      consumes 'multipart/form-data'
      produces 'application/json'

      parameter name: :case_id, in: :path, type: :integer, description: 'Case ID'
      parameter name: :hearing_id, in: :path, type: :integer, description: 'Hearing ID'
      parameter name: :document_params, in: :formData, schema: {
        type: :object,
        properties: {
          document_status: { type: :string },
          document: {
            type: :string,
            format: :binary,
            description: 'Document file to upload'
          }
        },
        required: [:document]
      }

      context 'when role is clerk and hearing is post hearing' do
        subject(:create_document) do
          post api_v1_case_hearing_case_documents_path(court_case, hearing), params: { document: valid_document_params }
          response
        end

        before { sign_in clerk_user }

        let(:valid_document_params) do
          {
            hash_value: Faker::Lorem.sentence,
            document_status: :pending,
            document: Rack::Test::UploadedFile.new('spec/support/documents/dummy.pdf', 'application/pdf')
          }
        end
        let!(:clerk_participant) do
          FactoryBot.create(:case_participant, case: court_case, user: clerk_user, role: Role.find_by(name: 'Clerk'))
        end

        response '201', 'Case Documents Created' do
          schema type: :object,
                 properties: {
                   id: { type: :integer },
                   hearing_id: { type: :integer },
                   verified_by_judge: { type: :boolean },
                   verified_at: { type: :string, format: 'date-time' },
                   document_status: { type: :string },
                   document: {
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
          it { expect { create_document }.to change(CaseDocument, :count).by(1) }

          it 'attach the document' do
            create_document
            expect(CaseDocument.last.document).to be_attached
          end

          it 'create document with correct status' do
            create_document
            expect(CaseDocument.last.document_status).to eq(valid_document_params[:document_status].to_s)
          end
        end
      end
    end
  end

  path 'api_v1_case_hearing_case_document' do
    put 'Update the case document' do
      tags 'Case Documents'
      security [Bearer: []]
      consumes 'multipart/form-data'
      produces 'application/json'

      parameter name: :case_id, in: :path, type: :integer, description: 'Case ID'
      parameter name: :hearing_id, in: :path, type: :integer, description: 'Hearing ID'
      parameter name: :document_params, in: :formData, schema: {
        type: :object,
        properties: {
          document_status: { type: :string },
          verified_by_judge: { type: :boolean },
          verified_at: { type: :datetime, format: 'date-time' }
        }
      }

      context 'when role is clerk and hearing is post hearing' do
        subject(:update_document) do
          put api_v1_case_hearing_case_document_path(court_case, hearing, case_document),
              params: { document: valid_document_params }
          response
        end

        before { sign_in clerk_user }

        let(:valid_document_params) do
          {
            document_status: :pending,
            verified_by_judge: false,
            verified_at: Time.zone.now
          }
        end
        let!(:case_document) { create(:case_document, :with_document, hearing: hearing) }
        let!(:clerk_participant) do
          FactoryBot.create(:case_participant, case: court_case, user: clerk_user, role: Role.find_by(name: 'Clerk'))
        end

        response '201', 'Case Documents Updated' do
          schema type: :object,
                 properties: {
                   id: { type: :integer },
                   hearing_id: { type: :integer },
                   document_status: { type: :string },
                   verified_by_judge: { type: :boolean },
                   verified_at: { type: :datetime, format: 'date-time' }
                 }

          it { is_expected.to have_http_status :ok }
          it { expect { update_document }.not_to change(CaseDocument, :count) }

          it 'update document with correct status' do
            update_document
            expect(CaseDocument.last.document_status).to eq(valid_document_params[:document_status].to_s)
          end
        end
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup
end
