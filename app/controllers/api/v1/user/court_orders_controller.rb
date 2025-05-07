# frozen_string_literal: true

module Api
  module V1
    module User
      # Court Orders for User
      class CourtOrdersController < ApplicationController
        before_action :authenticate_user!

        def received
          @court_orders = current_user.received_court_orders.includes(:case, :issuance_court, :issuing_user)
          authorize @court_orders
          render_json :ok, nil, serialized_court_orders(@court_orders)
        end

        private

        def serialized_court_orders(court_orders)
          court_orders.map do |court_order|
            CourtOrderSerializer.new(court_order).serializable_hash[:data][:attributes]
          end
        end
      end
    end
  end
end
