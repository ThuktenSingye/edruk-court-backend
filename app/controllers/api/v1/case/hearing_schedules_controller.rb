# frozen_string_literal: true

module Api
  module V1
    module Case
      # Hearing Schedule Controller
      class HearingSchedulesController < ApplicationController
        before_action :authenticate_user!
        before_action :case
        before_action :hearing
        before_action :hearing_schedule, only: %i[update destroy]

        def index
          # binding.pry
          @hearing_schedules = policy_scope(@hearing.hearing_schedules)
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
        end

        def update
          if @hearing_schedule.update(hearing_schedules_params)
            render_json :ok, 'Schedule Updated Successfully', serialized_hearing_schedule(@hearing_schedule)
          else
            render_json :unprocessable_entity, 'Failed to Update Schedule', @hearing_schedule.errors
          end
        end

        def destroy
          if @hearing_schedule.destroy
            render_json :ok, 'Schedule Deleted Successfully', serialized_hearing_schedule(@hearing_schedule)
          else
            render_json :unprocessable_entity, 'Failed to Delete Schedule', @hearing_schedule.errors
          end
        end

        private

        def case
          @case ||= current_tenant.cases.find(params[:case_id])
        end

        def hearing
          @hearing ||= @case.hearings.find(params[:hearing_id])
        end

        def hearing_schedule
          @hearing_schedule ||= @hearing.hearing_schedules.find(params[:id])
          authorize @hearing_schedule
        end

        def serialized_hearing_schedules(hearing_schedules)
          hearing_schedules.map do |schedule|
            HearingScheduleSerializer.new(schedule).serializable_hash[:data][:attributes]
          end
        end

        def serialized_hearing_schedule(hearing_schedule)
          HearingScheduleSerializer.new(hearing_schedule).serializable_hash[:data][:attributes]
        end

        def hearing_schedules_params
          params.expect(hearing_schedule: %i[scheduled_date schedule_status reschedule_reason scheduled_by])
        end
      end
    end
  end
end
