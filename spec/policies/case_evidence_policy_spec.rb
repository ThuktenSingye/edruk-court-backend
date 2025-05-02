# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup, Style/GlobalVars
RSpec.describe CaseEvidencePolicy, type: :policy do
  let(:case_type) { create(:case_type) }
  let(:case_subtype) { create(:case_subtype, case_type: case_type) }
  let!(:court_case) { create(:case, case_subtype: case_subtype, court: $default_account) }
  let(:hearing_type) { create(:hearing_type) }
  let(:hearing) { create(:hearing, case: court_case, hearing_type: hearing_type) }
  let(:miscellaneous_hearing_type) { create(:hearing_type, :miscellaneous) }
  let(:miscellaneous_hearing) { create(:hearing, hearing_type: miscellaneous_hearing_type, case: court_case) }

  let(:registrar_user) { create(:user, :registrar, confirmed_at: Time.zone.now) }
  # context 'when role is clerk and hearing is preliminary' do
  let(:judge_user) do
    create(:user, :judge, confirmed_at: Time.zone.now)
  end
  #   subject(:update_hearing_schedule) do
  #     put api_v1_case_hearing_hearing_schedule_path(court_case, preliminary_hearing, hearing_schedule),
  #         params: { hearing_schedule: valid_params }
  #     response
  #   end
  #
  #   let(:valid_params) do
  #     {
  #       scheduled_date: Faker::Date.forward(days: 2),
  #       schedule_status: 'approved',
  #       reschedule_reason: Faker::Lorem.paragraph
  #     }
  #   end
  #
  #   let!(:preliminary_hearing_type) { FactoryBot.create(:hearing_type, :preliminary) }
  #   let!(:preliminary_hearing) do
  #     FactoryBot.create(:hearing, case: court_case, hearing_type: preliminary_hearing_type)
  #   end
  #   let!(:clerk_participant) do
  #     FactoryBot.create(:case_participant, case: court_case, users: clerk_user, role: Role.find_by(name: 'Clerk'))
  #   end
  #
  #   let!(:judge_participant) do
  #     FactoryBot.create(:case_participant, case: court_case, users: judge_user, role: Role.find_by(name: 'Judge'))
  #   end
  #
  #   let!(:hearing_schedule) do
  #     FactoryBot.create(:hearing_schedule, hearing: preliminary_hearing, scheduled_by: clerk_user)
  #   end
  #
  #   before { sign_in clerk_user }
  #
  #   response '200', 'Hearing schedule updated' do
  #     schema type: :object,
  #            properties: {
  #              scheduled_date: { type: :string, format: 'date' },
  #              schedule_status: { type: :string },
  #              reschedule_reason: { type: :string },
  #              scheduled_by_id: { type: :integer }
  #            }
  #
  #     it { is_expected.to have_http_status :ok }
  #     it { expect { update_hearing_schedule }.to change(Noticed::Notification, :count).by(1) }
  #
  #
  #     it 'send notification' do
  #       update_hearing_schedule
  #       notification = Noticed::Notification.last
  #       expect(notification.recipient).to eq(judge_participant.users)
  #       expect(notification.params[:message]).to eq('schedule_update')
  #             #     end
  #   end
  # end
  let(:clerk_user) { create(:user, :clerk, confirmed_at: Time.zone.now) }

  describe 'permissions' do
    context 'when role is registrar and hearing is pre hearing' do
      subject { described_class.new(registrar_user, case_evidence) }

      let(:case_evidence) { create(:case_evidence, :with_image, hearing: miscellaneous_hearing) }

      it { is_expected.to permit_actions(%i[index create update destroy]) }
    end

    context 'when role is registrar and hearing is post hearing' do
      subject { described_class.new(registrar_user, case_evidence) }

      let(:case_evidence) { create(:case_evidence, :with_image, hearing: hearing) }

      it { is_expected.to forbid_actions(%i[create update destroy]) }
    end

    context 'when role is judge and the hearing is pre hearing' do
      subject { described_class.new(judge_user, case_evidence) }

      let(:case_evidence) { create(:case_evidence, :with_image, hearing: miscellaneous_hearing) }

      it { is_expected.to forbid_actions(%i[create update destroy]) }
    end

    context 'when role is judge and the hearing is post hearing' do
      subject { described_class.new(judge_user, case_evidence) }

      let(:case_evidence) { create(:case_evidence, :with_image, hearing: hearing) }

      let!(:case_participant) do
        create(:case_participant, case: court_case, user: judge_user,
                                  role: Role.find_by(name: 'Judge'))
      end

      it { is_expected.to permit_actions(%i[index create update destroy]) }
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers, RSpec/LetSetup, Style/GlobalVars
end
