# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable  RSpec/MultipleMemoizedHelpers,RSpec/LetSetup
RSpec.describe 'Api::V1::Case::Hearings', type: :request do
  let(:court) { FactoryBot.create(:court) }
  let(:user) { FactoryBot.create(:user, confirmed_at: Time.zone.now) }
  let(:case_type) { FactoryBot.create(:case_type) }
  let(:case_subtype) { FactoryBot.create(:case_subtype, case_type: case_type) }
  let!(:court_case) { FactoryBot.create(:case, case_subtype: case_subtype, court: court) }
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

  let(:registrar_user) { FactoryBot.create(:user, :registrar, court: court, confirmed_at: Time.zone.now) }
  let(:judge_user) { FactoryBot.create(:user, :judge, court: court, confirmed_at: Time.zone.now) }
  let(:clerk_user) { FactoryBot.create(:user, :clerk, court: court, confirmed_at: Time.zone.now) }

  describe 'GET /index' do
    before { sign_in judge_user }

    context 'when role is judge' do
      subject(:get_all_hearing) do
        get api_v1_case_hearings_path(court_case)
        response
      end

      it { is_expected.to have_http_status :ok }
    end
  end

  describe 'PUT /update' do
    context 'when role is judge and hearing is not miscellaneous' do
      subject(:update_hearing) do
        put api_v1_case_hearing_path(court_case, hearing), params: { hearing: valid_hearing_params }
        response
      end

      before { sign_in judge_user }

      let(:valid_hearing_params) do
        {
          hearing_status: :completed,
          hearing_type_id: hearing_type.id
        }
      end
      let!(:case_participant) do
        FactoryBot.create(:case_participant, case: court_case, user: judge_user,
                                             role: Role.find_by(name: 'Judge'))
      end

      it { is_expected.to have_http_status :ok }
      it { expect { update_hearing }.not_to change(Hearing, :count) }

      it 'update the status to completed' do
        response = update_hearing
        response_json = JSON.parse(response.body)
        expect(response_json['data']['hearing_status']).to eq(valid_hearing_params[:hearing_status].to_s)
      end
    end

    context 'when role is clerk and hearing is miscellaneous' do
      subject(:update_hearing) do
        put api_v1_case_hearing_path(court_case, miscellaneous_hearing), params: { hearing: valid_hearing_params }
        response
      end

      before { sign_in clerk_user }

      let(:valid_hearing_params) do
        {
          hearing_status: :completed,
          hearing_type_id: hearing_type.id
        }
      end
      let!(:case_participant) do
        FactoryBot.create(:case_participant, case: court_case, user: clerk_user,
                                             role: Role.find_by(name: 'Clerk'))
      end

      it { is_expected.to have_http_status :unauthorized }
      it { expect { update_hearing }.not_to change(Hearing, :count) }
    end

    context 'when role is general user' do
      subject(:update_hearing) do
        put api_v1_case_hearing_path(court_case, hearing), params: { hearing: valid_hearing_params }
        response
      end

      before { sign_in user }

      let(:valid_hearing_params) do
        {
          hearing_status: :completed
        }
      end

      it { is_expected.to have_http_status :unauthorized }

      it 'assign the original hearing' do
        update_hearing
        expect(assigns(:hearing)).to eq(hearing)
      end
    end
  end

  describe 'POST /create' do
    context 'when role is judge and hearing is miscellaneous' do
      subject(:create_hearing) do
        post api_v1_case_hearings_path(court_case), params: { hearing: valid_hearing_params }
        response
      end

      before { sign_in judge_user }

      let(:valid_hearing_params) do
        {
          hearing_status: :completed,
          hearing_type_id: miscellaneous_hearing_type.id
        }
      end

      it { is_expected.to have_http_status :unauthorized }
      it { expect { create_hearing }.not_to change(Hearing, :count) }
    end

    context 'when role is registrar and hearing is miscellaneous' do
      subject(:create_hearing) do
        post api_v1_case_hearings_path(court_case), params: { hearing: valid_hearing_params }
        response
      end

      before { sign_in registrar_user }

      let(:valid_hearing_params) do
        {
          hearing_status: :ongoing,
          hearing_type_id: miscellaneous_hearing_type.id,
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

      let!(:case_participant) do
        FactoryBot.create(:case_participant, case: court_case, user: judge_user,
                                             role: Role.find_by(name: 'Judge'))
      end

      it { expect { create_hearing }.to change { Noticed::Notification.where(recipient: judge_user).count }.by(1) }
      it { is_expected.to have_http_status :created }
    end

    context 'when role is clerk but params are invalid' do
      subject(:create_hearing) do
        post api_v1_case_hearings_path(court_case), params: { hearing: invalid_hearing_params }
        response
      end

      before { sign_in clerk_user }

      let(:invalid_hearing_params) do
        {
          hearing_status: nil,
          hearing_type_id: hearing_type.id
        }
      end
      let!(:case_participant) do
        FactoryBot.create(:case_participant, case: court_case, user: clerk_user,
                                             role: Role.find_by(name: 'Clerk'))
      end

      it { is_expected.to have_http_status :unprocessable_entity }
      it { expect { create_hearing }.not_to change(Hearing, :count) }
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers,RSpec/LetSetup
