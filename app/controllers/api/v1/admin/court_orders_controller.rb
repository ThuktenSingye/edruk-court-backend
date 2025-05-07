# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Court Order Controller for Admin
      class CourtOrdersController < BaseController
        def sent
          @court_orders = CourtOrder.where(issuing_user_id: current_user.id).includes(:case, :issuance_court)
          authorize @court_orders
          render_json :ok, nil, serialized_court_orders(@court_orders)
        end

        def show
          authorize @court_order
          render_json :ok, nil, serialized_court_order(@court_order)
        end

        def create
          @court_order = CourtOrder.build(court_order_params)
          @court_order.issuing_user = current_user
          authorize @court_order, policy_class: CourtOrderPolicy
          if @court_order.save
            render_json :created, 'Court Order successfully send.', serialized_court_order(@court_order)
          else
            render_json :unprocessable_entity, 'Failed to send court order', serialized_court_order(@court_order)
          end
        end

        private

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
end
