# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable  RSpec/MultipleMemoizedHelpers,RSpec/LetSetup
RSpec.describe 'Api::V1::Case::HearingSchedules', type: :request do
  let(:court) { FactoryBot.create(:court) }
  let(:user) { FactoryBot.create(:user, confirmed_at: Time.zone.now) }
  let(:case_type) { FactoryBot.create(:case_type, :civil) }
  let(:case_subtype) { FactoryBot.create(:case_subtype, case_type: case_type) }
  let!(:court_case) { FactoryBot.create(:case, case_subtype: case_subtype, case_type: case_type, court: court) }
  let!(:hearing_type) { FactoryBot.create(:hearing_type) }
  let!(:hearing) { FactoryBot.create(:hearing, case: court_case, hearing_type: hearing_type) }

  let(:registrar_user) { FactoryBot.create(:user, :registrar, court: court, confirmed_at: Time.zone.now) }
  let(:judge_user) { FactoryBot.create(:user, :judge, court: court, confirmed_at: Time.zone.now) }
  let(:clerk_user) { FactoryBot.create(:user, :clerk, court: court, confirmed_at: Time.zone.now) }

  let(:valid_schedule_params) do
    {
      scheduled_data: Faker::Date.forward(days: 2),
      schedule_status: :pending,
      reschedule_reason: Faker::Lorem.paragraph
    }
  end

  describe 'GET /index' do
    before { sign_in judge_user }

    context 'when role is judge' do
      subject(:get_all_schedules) do
        get api_v1_case_hearing_hearing_schedules_path(court_case, hearing)
        response
      end

      it { is_expected.to have_http_status :ok }
    end
  end

  # describe 'PUT /update' do
  #   context 'when role is registrar' do
  #     subject(:update_hearing_schedule) do
  #       put api_v1_case_hearing_hearing_schedule_path(court_case, hearing, hearing_schedule),
  #           params: { hearing_schedule: valid_schedule_params }
  #       response
  #     end
  #
  #     before { sign_in registrar_user }
  #
  #     let!(:hearing_schedule) do
  #       FactoryBot.create(:hearing_schedule, hearing: hearing, scheduled_by: registrar_user)
  #     end
  #
  #     it { is_expected.to have_http_status :unauthorized }
  #     it { expect { update_hearing_schedule }.not_to change(Hearing, :count) }
  #   end
  #
  #   context 'when role is clerk' do
  #     subject(:update_hearing_schedule) do
  #       put api_v1_case_hearing_hearing_schedule_path(court_case, hearing, hearing_schedule),
  #           params: { hearing_schedule: valid_schedule_params }
  #       response
  #     end
  #
  #     before { sign_in clerk_user }
  #
  #     let!(:case_participant) do
  #       FactoryBot.create(:case_participant, case: court_case, user: clerk_user,
  #                         role: Role.find_by(name: 'Clerk'))
  #     end
  #     let!(:hearing_schedule) do
  #       FactoryBot.create(:hearing_schedule, hearing: hearing, scheduled_by: clerk_user)
  #     end
  #
  #
  #     it { is_expected.to have_http_status :ok }
  #     it { expect { update_hearing_schedule }.not_to change(Hearing, :count) }
  #   end
  #
  #
  #   context 'when role is judge and hearing is preliminary' do
  #     subject(:update_hearing_schedule) do
  #       put api_v1_case_hearing_hearing_schedule_path(court_case, preliminary_hearing, hearing_schedule),
  #           params: { hearing_schedule: valid_schedule_params }
  #       response
  #     end
  #
  #     before { sign_in judge_user }
  #
  #     let!(:preliminary_hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
  #     let!(:preliminary_hearing) do
  #       FactoryBot.create(:hearing, case: court_case, hearing_type: preliminary_hearing_type)
  #     end
  #     let!(:case_participant) do
  #       FactoryBot.create(:case_participant, case: court_case, user: judge_user,
  #                                            role: Role.find_by(name: 'Judge'))
  #     end
  #     let!(:hearing_schedule) do
  #       FactoryBot.create(:hearing_schedule, hearing: preliminary_hearing, scheduled_by: clerk_user)
  #     end
  #
  #     it { is_expected.to have_http_status :ok }
  #     it { expect { update_hearing_schedule }.not_to change(Hearing, :count) }
  #
  #     it 'update the status to pending' do
  #       response = update_hearing_schedule
  #       response_json = JSON.parse(response.body)
  #       expect(response_json['data']['schedule_status']).to eq(valid_schedule_params[:schedule_status].to_s.humanize)
  #     end
  #   end
  #
  #   context 'when role is registrar and hearing is miscellaneous' do
  #     subject(:update_hearing_schedule) do
  #       put api_v1_case_hearing_hearing_schedule_path(court_case, miscellaneous_hearing, hearing_schedule),
  #           params: { hearing_schedule: valid_schedule_params }
  #       response
  #     end
  #
  #     before { sign_in registrar_user }
  #
  #     let!(:miscellaneous_hearing_type) { FactoryBot.create(:hearing_type, :miscellaneous) }
  #     let!(:miscellaneous_hearing) do
  #       FactoryBot.create(:hearing, case: court_case, hearing_type: miscellaneous_hearing_type)
  #     end
  #     let!(:hearing_schedule) do
  #       FactoryBot.create(:hearing_schedule, hearing: miscellaneous_hearing, scheduled_by: registrar_user)
  #     end
  #
  #     it { is_expected.to have_http_status :ok }
  #     it { expect { update_hearing_schedule }.not_to change(Hearing, :count) }
  #
  #     it 'update the status to pending' do
  #       response = update_hearing_schedule
  #       response_json = JSON.parse(response.body)
  #       expect(response_json['data']['schedule_status']).to eq(valid_schedule_params[:schedule_status].to_s.humanize)
  #     end
  #   end
  #
  #   context 'when role is registrar and hearing is preliminary' do
  #     subject(:update_hearing_schedule) do
  #       put api_v1_case_hearing_hearing_schedule_path(court_case, miscellaneous_hearing, hearing_schedule),
  #           params: { hearing_schedule: valid_schedule_params }
  #       response
  #     end
  #
  #     before { sign_in clerk_user }
  #
  #     let!(:miscellaneous_hearing_type) { FactoryBot.create(:hearing_type, :miscellaneous) }
  #     let!(:miscellaneous_hearing) do
  #       FactoryBot.create(:hearing, case: court_case, hearing_type: miscellaneous_hearing_type)
  #     end
  #     let!(:hearing_schedule) do
  #       FactoryBot.create(:hearing_schedule, hearing: miscellaneous_hearing, scheduled_by: registrar_user)
  #     end
  #
  #     it { is_expected.to have_http_status :unauthorized }
  #     it { expect { update_hearing_schedule }.not_to change(Hearing, :count) }
  #
  #     it 'assign the original hearing' do
  #       update_hearing_schedule
  #       expect(assigns(:hearing_schedule)).to eq(hearing_schedule)
  #     end
  #   end
  #
  #   context 'when role is clerk and hearing is miscellaneous' do
  #     subject(:update_hearing_schedule) do
  #       put api_v1_case_hearing_hearing_schedule_path(court_case, preliminary_hearing, hearing_schedule),
  #           params: { hearing_schedule: valid_schedule_params }
  #       response
  #     end
  #
  #     before { sign_in registrar_user }
  #
  #     let!(:preliminary_hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
  #     let!(:preliminary_hearing) do
  #       FactoryBot.create(:hearing, case: court_case, hearing_type: preliminary_hearing_type)
  #     end
  #     let!(:case_participant) do
  #       FactoryBot.create(:case_participant, case: court_case, user: clerk_user,
  #                                            role: Role.find_by(name: 'Clerk'))
  #     end
  #     let!(:hearing_schedule) do
  #       FactoryBot.create(:hearing_schedule, hearing: preliminary_hearing, scheduled_by: clerk_user)
  #     end
  #
  #     it { is_expected.to have_http_status :unauthorized }
  #     it { expect { update_hearing_schedule }.not_to change(Hearing, :count) }
  #
  #     it 'assign the original hearing' do
  #       update_hearing_schedule
  #       expect(assigns(:hearing_schedule)).to eq(hearing_schedule)
  #     end
  #   end
  # end

  describe 'DESTROY /destroy' do
    context 'when role is clerk user and hearing is preliminary' do
      subject(:delete_hearing_schedule) do
        delete api_v1_case_hearing_hearing_schedule_path(court_case, preliminary_hearing, hearing_schedule)
        response
      end

      before { sign_in clerk_user }

      let!(:preliminary_hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
      let!(:preliminary_hearing) do
        FactoryBot.create(:hearing, case: court_case, hearing_type: preliminary_hearing_type)
      end
      let!(:case_participant) do
        FactoryBot.create(:case_participant, case: court_case, user: clerk_user,
                                             role: Role.find_by(name: 'Clerk'))
      end
      let!(:hearing_schedule) do
        FactoryBot.create(:hearing_schedule, hearing: preliminary_hearing, scheduled_by: clerk_user)
      end

      it { is_expected.to have_http_status :ok }
      it { expect { delete_hearing_schedule }.to change(HearingSchedule, :count) }
    end

    context 'when role is judge user and hearing is preliminary' do
      subject(:delete_hearing_schedule) do
        delete api_v1_case_hearing_hearing_schedule_path(court_case, preliminary_hearing, hearing_schedule)
        response
      end

      before { sign_in judge_user }

      let!(:preliminary_hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
      let!(:preliminary_hearing) do
        FactoryBot.create(:hearing, case: court_case, hearing_type: preliminary_hearing_type)
      end
      let!(:case_participant) do
        FactoryBot.create(:case_participant, case: court_case, user: judge_user,
                                             role: Role.find_by(name: 'Judge'))
      end
      let!(:hearing_schedule) do
        FactoryBot.create(:hearing_schedule, hearing: preliminary_hearing, scheduled_by: clerk_user)
      end

      it { is_expected.to have_http_status :unauthorized }
      it { expect { delete_hearing_schedule }.not_to change(HearingSchedule, :count) }
    end
  end

  context 'when role is registrar and hearing is miscellaneous' do
    subject(:delete_hearing_schedule) do
      delete api_v1_case_hearing_hearing_schedule_path(court_case, miscellaneous_hearing, hearing_schedule)
      response
    end

    before { sign_in judge_user }

    let!(:miscellaneous_hearing_type) { FactoryBot.create(:hearing_type, :miscellaneous) }
    let!(:miscellaneous_hearing) do
      FactoryBot.create(:hearing, case: court_case, hearing_type: miscellaneous_hearing_type)
    end
    let!(:hearing_schedule) do
      FactoryBot.create(:hearing_schedule, hearing: miscellaneous_hearing, scheduled_by: registrar_user)
    end

    it { is_expected.to have_http_status :unauthorized }
    it { expect { delete_hearing_schedule }.not_to change(HearingSchedule, :count) }
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers,RSpec/LetSetup
