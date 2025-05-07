# frozen_string_literal: true

module Api
  module V1
    module User
      # Hearing Class for User
      class HearingsController < ApplicationController
        before_action :authenticate_user!
        before_action :cases
        before_action :case

        def index
          #  allow only approved hearing to be shown
          @hearings = policy_scope(@case.hearings.includes(:hearing_type, :hearing_schedules))
          authorize @hearings
          render_json :ok, nil, serialized_hearings(@hearings)
        end

        private

        def cases
          role_ids = Role.where(name: %w[Plaintiff Defendant]).pluck(:id)
          @cases ||= ::Case.joins(:case_participants).where(
            case_participants: {
              user_id: current_user.id,
              role_id: role_ids
            }
          ).distinct
        end

        def case
          @case ||= @cases.find_by(id: params[:case_id])
        end

        def serialized_hearings(hearings)
          hearings.map { |hearing| HearingSerializer.new(hearing).serializable_hash[:data][:attributes] }
        end

        def serialized_hearing(hearing)
          HearingSerializer.new(hearing).serializable_hash[:data][:attributes]
        end
      end
    end
  end
end
