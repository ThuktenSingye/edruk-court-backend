# frozen_string_literal: true

module Api
  module V1
    module User
      # Hearing Schedules Controller for User
      class HearingSchedulesController < ApplicationController
        before_action :authenticate_user!
        before_action :cases
        before_action :case, only: %i[index]
        before_action :hearing, only: %i[index]

        def index
          @hearing_schedules = policy_scope(@hearing.hearing_schedules).order(scheduled_date: :asc)
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
        end

        def reminders
          @hearing_schedules = policy_scope(
            HearingSchedule.reminder.for_accessible_cases(current_user)
          )
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
        end

        def list
          @hearing_schedules = policy_scope(
            HearingSchedule.for_accessible_cases(current_user)
          )
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
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

        def hearing
          @hearing ||= @case.hearings.find(params[:hearing_id])
        end

        def hearing_schedule_query
          HearingScheduleQuery.new(@hearing)
        end

        def serialized_hearing_schedules(hearing_schedules)
          hearing_schedules.map do |schedule|
            HearingScheduleSerializer.new(schedule).serializable_hash[:data][:attributes]
          end
        end

        def serialized_hearing_schedule(hearing_schedule)
          HearingScheduleSerializer.new(hearing_schedule).serializable_hash[:data][:attributes]
        end
      end
    end
  end
end
