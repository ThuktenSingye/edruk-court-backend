# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup, Style/GlobalVars
RSpec.describe 'Api::V1::Case::Notes', type: :request do
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

  # index
  path '/api/v1/case/:case_id/hearings/:hearing_id/notes' do
    get 'List all notes for a hearing' do
      tags 'Notes'
      security [Bearer: []]
      produces 'application/json'

      parameter name: :case_id, in: :path, type: :string, required: true, description: 'ID of the case'
      parameter name: :hearing_id, in: :path, type: :string, required: true, description: 'ID of the hearing'

      context 'when the user role is judge' do
        subject(:get_all_notes) do
          get api_v1_case_hearing_notes_path(court_case, hearing)
          response
        end

        let!(:note_one) { create(:note, hearing: hearing, user: judge_user) }
        let!(:judge_participant) do
          create(:case_participant, case: court_case, user: judge_user,
                                    role: Role.find_by(name: 'Judge'))
        end

        before { sign_in judge_user }

        response '200', 'Hearings found' do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     content: { type: :string },
                     created_at: { type: :datetime, format: :datetime }
                   }
                 }

          it 'returns all notes for the hearing' do
            get api_v1_case_hearing_notes_path(court_case, hearing)
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end
  # create
  path '/api/v1/cases/:case_id/hearings/:hearing_id/notes' do
    post 'Create a Hearing Note' do
      tags 'Notes'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :case_id, in: :path, type: :string, required: true, description: 'ID of the case'
      parameter name: :hearing_id, in: :path, type: :string, required: true, description: 'ID of the hearing'
      parameter name: :note, in: :body, schema: {
        type: :object,
        properties: {
          note: {
            type: :object,
            properties: {
              content: { type: :string }
            },
            required: [:content]
          }
        },
        required: [:note]
      }

      context 'when user is registrar and pre_hearing' do
        subject(:create_note) do
          post api_v1_case_hearing_notes_path(court_case, miscellaneous_hearing), params: { note: valid_note_params }
          response
        end

        let(:valid_note_params) { { content: Faker::Lorem.sentence } }

        before { sign_in registrar_user }

        response '201', 'Note Created' do
          schema type: :object,
                 properties: {
                   id: { type: :integer },
                   content: { type: :string },
                   created_at: { type: :string, format: 'date-time' },
                   user_id: { type: :integer }
                 }

          it { is_expected.to have_http_status :created }
          it { expect { create_note }.to change(Note, :count).by(1) }

          it 'create with correct note content' do
            create_note
            note = Note.last
            expect(note.content).to eq(valid_note_params[:content])
          end
        end
      end

      context 'when user is registrar and post_hearing' do
        subject(:create_note) do
          post api_v1_case_hearing_notes_path(court_case, preliminary_hearing), params: { note: valid_note_params }
          response
        end

        let(:valid_note_params) { { content: Faker::Lorem.sentence } }

        before { sign_in registrar_user }

        response '401', 'Unauthorized' do
          it { is_expected.to have_http_status :unauthorized }
          it { expect { create_note }.not_to change(Note, :count) }
        end
      end

      context 'when user is judge and post_hearing' do
        subject(:create_note) do
          post api_v1_case_hearing_notes_path(court_case, hearing), params: { note: valid_note_params }
          response
        end

        let(:valid_note_params) { { content: Faker::Lorem.sentence } }
        let!(:judge_participant) do
          create(:case_participant, case: court_case, user: judge_user,
                                    role: Role.find_by(name: 'Judge'))
        end

        before { sign_in judge_user }

        response '201', 'Note Created' do
          schema type: :object,
                 properties: {
                   id: { type: :integer },
                   content: { type: :string },
                   created_at: { type: :string, format: 'date-time' },
                   user_id: { type: :integer }
                 }

          it { is_expected.to have_http_status :created }
          it { expect { create_note }.to change(Note, :count).by(1) }

          it 'create with correct note content' do
            create_note
            note = Note.last
            expect(note.content).to eq(valid_note_params[:content])
          end
        end
      end

      context 'when user is judge and pre_hearing' do
        subject(:create_note) do
          post api_v1_case_hearing_notes_path(court_case, miscellaneous_hearing), params: { note: valid_note_params }
          response
        end

        let(:valid_note_params) { { content: Faker::Lorem.sentence } }

        before { sign_in judge_user }

        response '401', 'Unauthorized' do
          it { is_expected.to have_http_status :unauthorized }
          it { expect { create_note }.not_to change(Note, :count) }
        end
      end
    end
  end
  # update
  path '/api/v1/cases/:case_id/hearings/:hearing_id/notes/:id' do
    put 'Update a Hearing Note' do
      tags 'Notes'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :case_id, in: :path, type: :string, required: true, description: 'ID of the case'
      parameter name: :hearing_id, in: :path, type: :string, required: true, description: 'ID of the hearing'
      parameter name: :id, in: :path, type: :string, required: true, description: 'ID of the note'
      parameter name: :note_params, in: :body, schema: {
        type: :object,
        properties: {
          content: { type: :string }
        },
        required: [:content]
      }

      context 'when user is registrar and pre_hearing' do
        subject(:update_note) do
          put api_v1_case_hearing_note_path(court_case, miscellaneous_hearing, note),
              params: { note: valid_note_params }
          response
        end

        let(:valid_note_params) { { content: Faker::Lorem.sentence } }
        let!(:note) { create(:note, hearing: miscellaneous_hearing, user: registrar_user) }

        before { sign_in registrar_user }

        response '201', 'Note Created' do
          schema type: :object,
                 properties: {
                   id: { type: :integer },
                   content: { type: :string },
                   created_at: { type: :string, format: 'date-time' },
                   user_id: { type: :integer }
                 }

          it { is_expected.to have_http_status :ok }
          it { expect { update_note }.not_to change(Note, :count) }

          it 'create with correct note content' do
            update_note
            note = Note.last.reload
            expect(note.content).to eq(valid_note_params[:content])
          end
        end
      end

      context 'when user is registrar and pre_hearing but with invalid params' do
        subject(:update_note) do
          put api_v1_case_hearing_note_path(court_case, miscellaneous_hearing, note),
              params: { note: valid_note_params }
          response
        end

        let(:valid_note_params) { { content: nil } }
        let!(:note) { create(:note, hearing: miscellaneous_hearing, user: registrar_user) }

        before { sign_in registrar_user }

        response '201', 'Note Created' do
          schema type: :object,
                 properties: {
                   id: { type: :integer },
                   content: { type: :string },
                   created_at: { type: :string, format: 'date-time' },
                   user_id: { type: :integer }
                 }

          it { is_expected.to have_http_status :unprocessable_entity }
          it { expect { update_note }.not_to change(Note, :count) }
        end
      end

      context 'when user is registrar and post_hearing' do
        subject(:update_note) do
          put api_v1_case_hearing_note_path(court_case, hearing, note), params: { note: valid_note_params }
          response
        end

        let(:valid_note_params) { { content: Faker::Lorem.sentence } }
        let!(:note) { create(:note, hearing: hearing, user: registrar_user) }

        before { sign_in registrar_user }

        response '401', 'Unauthorized' do
          it { is_expected.to have_http_status :unauthorized }
          it { expect { update_note }.not_to change(Note, :count) }

          it 'does not update the note' do
            update_note
            expect(assigns(:note)).to eq(note)
          end
        end
      end

      context 'when user is judge and post_hearing' do
        subject(:update_note) do
          put api_v1_case_hearing_note_path(court_case, hearing, note), params: { note: valid_note_params }
          response
        end

        let(:valid_note_params) { { content: Faker::Lorem.sentence } }
        let!(:note) { create(:note, hearing: hearing, user: judge_user) }

        let!(:judge_participant) do
          create(:case_participant, case: court_case, user: judge_user,
                                    role: Role.find_by(name: 'Judge'))
        end

        before { sign_in judge_user }

        response '200', 'Note Updated' do
          schema type: :object,
                 properties: {
                   id: { type: :integer },
                   content: { type: :string },
                   created_at: { type: :string, format: 'date-time' },
                   user_id: { type: :integer }
                 }

          it { is_expected.to have_http_status :ok }
          it { expect { update_note }.not_to change(Note, :count) }

          it 'create with correct note content' do
            update_note
            note = Note.last
            expect(note.content).to eq(valid_note_params[:content])
          end
        end
      end

      context 'when user is judge and pre_hearing' do
        subject(:update_note) do
          put api_v1_case_hearing_note_path(court_case, miscellaneous_hearing, note),
              params: { note: valid_note_params }
          response
        end

        let(:valid_note_params) { { content: Faker::Lorem.sentence } }
        let!(:note) { create(:note, hearing: miscellaneous_hearing, user: judge_user) }

        before { sign_in judge_user }

        response '401', 'Unauthorized' do
          it { is_expected.to have_http_status :unauthorized }
          it { expect { update_note }.not_to change(Note, :count) }
        end
      end
    end
  end

  path '/api/v1/cases/:case_id/hearings/:hearing_id/notes/:id' do
    delete 'Destroy a Hearing Note' do
      tags 'Notes'
      security [Bearer: []]
      produces 'application/json'

      parameter name: :case_id, in: :path, type: :string, required: true, description: 'ID of the case'
      parameter name: :hearing_id, in: :path, type: :string, required: true, description: 'ID of the hearing'
      parameter name: :id, in: :path, type: :string, required: true, description: 'ID of the note'

      context 'when user is registrar and pre_hearing' do
        subject(:delete_note) do
          delete api_v1_case_hearing_note_path(court_case, miscellaneous_hearing, note),
                 params: { note: valid_note_params }
          response
        end

        let(:valid_note_params) { { content: Faker::Lorem.sentence } }
        let!(:note) { create(:note, hearing: miscellaneous_hearing, user: registrar_user) }

        before { sign_in registrar_user }

        response '201', 'Note Deleted' do
          schema type: :object,
                 properties: {
                   id: { type: :integer }
                 }

          it { is_expected.to have_http_status :ok }
          it { expect { delete_note }.to change(Note, :count).by(-1) }
        end
      end

      context 'when user is registrar and post_hearing' do
        subject(:delete_note) do
          delete api_v1_case_hearing_note_path(court_case, hearing, note),
                 params: { note: valid_note_params }
          response
        end

        let(:valid_note_params) { { content: Faker::Lorem.sentence } }
        let!(:note) { create(:note, hearing: hearing, user: registrar_user) }

        before { sign_in registrar_user }

        response '401', 'Unauthorized' do
          it { is_expected.to have_http_status :unauthorized }
          it { expect { delete_note }.not_to change(Note, :count) }
        end
      end

      context 'when user is judge and post_hearing' do
        subject(:delete_note) do
          delete api_v1_case_hearing_note_path(court_case, hearing, note),
                 params: { note: valid_note_params }
          response
        end

        let(:valid_note_params) { { content: Faker::Lorem.sentence } }
        let!(:note) { create(:note, hearing: hearing, user: judge_user) }

        let!(:judge_participant) do
          create(:case_participant, case: court_case, user: judge_user,
                                    role: Role.find_by(name: 'Judge'))
        end

        before { sign_in judge_user }

        response '200', 'Note Deleted' do
          schema type: :object,
                 properties: {
                   id: { type: :integer }
                 }

          it { is_expected.to have_http_status :ok }
          it { expect { delete_note }.to change(Note, :count).by(-1) }
        end
      end

      context 'when user is judge and pre_hearing' do
        subject(:delete_note) do
          delete api_v1_case_hearing_note_path(court_case, miscellaneous_hearing, note),
                 params: { note: valid_note_params }
          response
        end

        let(:valid_note_params) { { content: Faker::Lorem.sentence } }
        let!(:note) { create(:note, hearing: miscellaneous_hearing, user: judge_user) }

        before { sign_in judge_user }

        response '401', 'Unauthorized' do
          it { is_expected.to have_http_status :unauthorized }
          it { expect { delete_note }.not_to change(Note, :count) }
        end
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup, Style/GlobalVars
end
