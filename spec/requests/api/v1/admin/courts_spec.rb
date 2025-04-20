# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::V1::Admin::Courts', type: :request do
  include AuthHelper
  let!(:admin) { create(:user, :admin) }
  let(:court) { create(:court) }
  # let(:headers) { auth_headers(admin) }

  path 'api/v1/admin/courts' do
    get 'List all courts' do
      tags 'Courts'
      security [Bearer: []]
      produces 'application/json'

      context 'when role is admin' do
        subject(:list_court) do
          get api_v1_admin_courts_path
          response
        end

        before { sign_in admin }

        response '200', 'Successful' do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     court_type: { type: :string },
                     email: { type: :string },
                     subdomain: { type: :string },
                     domain: { type: :string },
                     parent_court: {
                       id: { type: :integer },
                       name: { type: :string },
                       court_type: { type: :string }
                     }
                   }
                 }
          it { is_expected.to have_http_status :ok }
        end
      end
    end
  end

  # path 'api/v1/admin/courts/:id' do
  #   get 'show a courts' do
  #     tags 'Courts'
  #     security [Bearer: []]
  #     produces 'application/json'
  #
  #     parameter name: :id, in: :path, type: :string, description: 'Court id.'
  #
  #     context 'when role is admin' do
  #       subject(:list_court) do
  #         get api_v1_admin_court_path(court), headers: auth_headers
  #         response
  #       end
  #
  #       before { sign_in admin }
  #
  #       response '200', 'Successful' do
  #         schema type: :array,
  #                items: {
  #                  type: :object,
  #                  properties: {
  #                    id: { type: :integer },
  #                    name: { type: :string },
  #                    court_type: { type: :string },
  #                    email: { type: :string },
  #                    subdomain: { type: :string },
  #                    domain: { type: :string },
  #                    parent_court: {
  #                      id: { type: :integer },
  #                      name: { type: :string },
  #                      court_type: { type: :string }
  #                    }
  #                  }
  #                }
  #         it { is_expected.to have_http_status :ok }
  #       end
  #     end
  #   end
  # end
  #
  # path 'api/v1/admin/courts' do
  #   post 'Create a court' do
  #     tags 'Courts'
  #     security [Bearer: []]
  #     consumes 'application/json'
  #     produces 'application/json'
  #
  #     parameter name: :court_params, in: :body, schema: {
  #       type: :object,
  #       properties: {
  #         name: { type: :string },
  #         court_type: { type: :string },
  #         email: { type: :string },
  #         contact_no: { type: :string },
  #         subdomain: { type: :string },
  #         domain: { type: :string },
  #         parent_court_id: { type: :integer }
  #       }
  #     }
  #
  #     context 'when role is admin' do
  #       subject(:create_court) do
  #         post api_v1_admin_courts_path, params: { court: valid_court_params }
  #         response
  #       end
  #
  #       before { sign_in admin }
  #
  #       let(:valid_court_params) do
  #         {
  #           name: Faker::Name.unique.name,
  #           court_type: :dungkhag,
  #           email: Faker::Internet.unique.email,
  #           contact_no: Faker::Number.number(digits: 8),
  #           subdomain: Faker::Internet.unique.domain_name,
  #           domain: Faker::Internet.unique.domain_name,
  #           parent_court_id: court.id
  #         }
  #       end
  #
  #       response '201', 'Court created' do
  #         schema type: :object,
  #                properties: {
  #                  name: { type: :string },
  #                  court_type: { type: :string },
  #                  email: { type: :string },
  #                  contact_no: { type: :string },
  #                  subdomain: { type: :string },
  #                  domain: { type: :string },
  #                  parent_court: {
  #                    id: { type: :integer },
  #                    name: { type: :string },
  #                    court_type: { type: :string }
  #                  }
  #                }
  #
  #         it { is_expected.to have_http_status :created }
  #         it { expect { create_court }.to change(Court, :count).by(1) }
  #       end
  #     end
  #   end
  # end
  #
  # path 'api/v1/admin/courts/:id' do
  #   put 'Update a court' do
  #     tags 'Courts'
  #     security [Bearer: []]
  #     consumes 'application/json'
  #     produces 'application/json'
  #
  #     parameter name: :id, in: :path, type: :string, description: 'Court id.'
  #     parameter name: :court_params, in: :body, schema: {
  #       type: :object,
  #       properties: {
  #         name: { type: :string },
  #         court_type: { type: :string },
  #         email: { type: :string },
  #         contact_no: { type: :string },
  #         subdomain: { type: :string },
  #         domain: { type: :string },
  #         parent_court_id: { type: :integer }
  #       }
  #     }
  #
  #     context 'when role is admin' do
  #       subject(:create_court) do
  #         put api_v1_admin_court_path(court), params: { court: valid_court_params }
  #         response
  #       end
  #
  #       before { sign_in admin }
  #
  #       let(:valid_court_params) do
  #         {
  #           name: Faker::Name.unique.name,
  #           court_type: :dungkhag,
  #           email: Faker::Internet.unique.email,
  #           contact_no: Faker::Number.number(digits: 8),
  #           subdomain: Faker::Internet.unique.domain_name,
  #           domain: Faker::Internet.unique.domain_name,
  #           parent_court_id: court.id
  #         }
  #       end
  #
  #       response '200', 'Court updated' do
  #         schema type: :object,
  #                properties: {
  #                  name: { type: :string },
  #                  court_type: { type: :string },
  #                  email: { type: :string },
  #                  contact_no: { type: :string },
  #                  subdomain: { type: :string },
  #                  domain: { type: :string },
  #                  parent_court: {
  #                    id: { type: :integer },
  #                    name: { type: :string },
  #                    court_type: { type: :string }
  #                  }
  #                }
  #
  #         it { is_expected.to have_http_status :ok }
  #       end
  #     end
  #   end
  # end
end
