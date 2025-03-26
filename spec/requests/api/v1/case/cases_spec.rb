# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable  RSpec/MultipleMemoizedHelpers
RSpec.describe 'Api::V1::Case::Cases', type: :request do
  let(:court) { FactoryBot.create(:court) }
  let!(:user) { FactoryBot.create(:user, :court_user, court: court, confirmed_at: Time.zone.now) }
  let(:case_type) { FactoryBot.create(:case_type) }
  let(:case_subtype) { FactoryBot.create(:case_subtype, case_type: case_type) }
  let!(:court_case) { FactoryBot.create(:case, case_subtype: case_subtype, court: court) }

  describe 'GET /show' do
    before { sign_in user }

    context 'when case record exists' do
      subject(:get_case) do
        get api_v1_case_path(court_case)
        response
      end

      it { is_expected.to have_http_status :ok }
    end
  end

  describe 'POST /create' do
    let(:clerk_user) { FactoryBot.create(:user, :clerk, confirmed_at: Time.zone.now) }
    let(:registrar_user) { FactoryBot.create(:user, :registrar, confirmed_at: Time.zone.now) }

    context 'when role is not registrar' do
      subject(:create_post) do
        post api_v1_cases_path, params: { case: case_params }
        response
      end

      before { sign_in clerk_user }

      let(:case_params) { FactoryBot.attributes_for(:case) }

      it { is_expected.to have_http_status :unauthorized }
      it { expect { create_post }.not_to change(Case, :count) }
    end

    context 'when role is registrar' do
      subject(:create_post) do
        post api_v1_cases_path, params: { case: case_params }
        response
      end

      before do
        sign_in registrar_user
      end

      let(:case_params) { FactoryBot.attributes_for(:case) }

      it { is_expected.to have_http_status :created }
      it { expect { create_post }.to change(Case, :count).by(1) }
    end
  end

  describe 'PUT /update' do
    let(:registrar_user) { FactoryBot.create(:user, :registrar, confirmed_at: Time.zone.now) }
    let(:judge_user) { FactoryBot.create(:user, :judge, confirmed_at: Time.zone.now) }

    context 'when role is judge' do
      subject(:update_case) do
        put api_v1_case_path(court_case), params: { case: case_params }
        response
      end

      before { sign_in judge_user }

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

      it { is_expected.to have_http_status :unauthorized }
      it { expect { update_case }.not_to change(Case, :count) }

      it 'assigns the original employee' do
        update_case
        expect(assigns(:case)).to eq(court_case)
      end
    end

    context 'when role is registrar' do
      subject(:update_case) do
        put api_v1_case_path(court_case), params: { case: case_params }
        response
      end

      before { sign_in registrar_user }

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

      it { is_expected.to have_http_status :ok }
      it { expect { update_case }.not_to change(Case, :count) }

      # rubocop:disable RSpec/ExampleLength
      it 'update case with correct attributes' do
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
      # rubocop:enable RSpec/ExampleLength
    end
  end

  describe 'GET /statistics' do
    let(:registrar_user) { FactoryBot.create(:user, :registrar, confirmed_at: Time.zone.now) }
    let(:general_user) { FactoryBot.create(:user, confirmed_at: Time.zone.now) }

    context 'when user is not court official' do
      subject(:get_statistics) do
        get statistics_api_v1_cases_path
        response
      end

      before { sign_in general_user }

      it { is_expected.to have_http_status :unauthorized }
    end

    context 'when user is court official' do
      subject(:get_statistics) do
        get statistics_api_v1_cases_path
        response
      end

      before { sign_in registrar_user }

      it { is_expected.to have_http_status :ok }
    end
  end
  # rubocop:enable  RSpec/MultipleMemoizedHelpers
end
