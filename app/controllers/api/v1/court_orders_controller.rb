# frozen_string_literal: true

module Api
  module V1
    # Court Order Controller
    class CourtOrdersController < ApplicationController
      before_action :authenticate_user!
      before_action :court
      before_action :court_order, only: [:show]

      def sent
        @court_orders = @court.issued_court_orders.includes(:case, :issuing_user)
        authorize @court_orders
        render_json :ok, nil, serialized_court_orders(@court_orders)
      end

      def received
        @court_orders = @court.received_court_orders.includes(:case, :issuing_user)
        authorize @court_orders
        render_json :ok, nil, serialized_court_orders(@court_orders)
      end

      def show
        authorize @court_order
        render_json :ok, nil, serialized_court_order(@court_order)
      end

      def create
        @court_order = CourtOrder.build(court_order_params)
        @court_order.issuance_court = @court
        @court_order.issuing_user = current_user
        authorize @court_order
        if @court_order.save
          render_json :created, 'Court Order successfully send.', serialized_court_order(@court_order)
        else
          render_json :unprocessable_entity, 'Failed to send court order', @court_order.errors
        end
      end

      private

      def court
        @court ||= current_tenant.bench? ? current_tenant.parent_court : current_tenant
      end

      def court_order
        @court_order ||= CourtOrder.find(params[:id])
      end

      def serialized_court_orders(court_orders)
        court_orders.map do |court_order|
          CourtOrderSerializer.new(court_order).serializable_hash[:data][:attributes]
        end
      end

      def serialized_court_order(court_order)
        CourtOrderSerializer.new(court_order).serializable_hash[:data][:attributes]
      end

      # rubocop:disable Rails/StrongParametersExpect
      def court_order_params
        params.require(:court_order).permit(
          :message, :order_type, :case_id, documents: [],
                                           order_recipient_courts_attributes: %i[court_id _destroy],
                                           order_recipient_users_attributes: %i[user_id _destroy]
        )
      end
      # rubocop:enable Rails/StrongParametersExpect
    end
  end
end
