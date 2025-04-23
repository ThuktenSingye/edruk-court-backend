# frozen_string_literal: true

module Api
  module V1
    module Case
      # Hearing Schedule Controller
      class HearingSchedulesController < ApplicationController
        before_action :authenticate_user!
        before_action :case, only: %i[index update destroy]
        before_action :hearing, only: %i[index update destroy]
        before_action :hearing_schedule, only: %i[update destroy]

        def index
          @hearing_schedules = policy_scope(@hearing.hearing_schedules).order(scheduled_date: :asc)
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
        end

        def update
          if @hearing_schedule.update(hearing_schedules_params)
            Schedules::HearingScheduleService.new(@case, @hearing, @hearing_schedule, current_user).notify
            render_json :ok, 'Schedule Updated Successfully', serialized_hearing_schedule(@hearing_schedule)
          else
            render_json :unprocessable_entity, 'Failed to Update Schedule', @hearing_schedule.errors
          end
        end

        def destroy
          if @hearing_schedule.destroy
            Schedules::HearingScheduleService.new(@case, @hearing, @hearing_schedule, current_user).notify
            render_json :ok, 'Schedule Deleted Successfully', serialized_hearing_schedule(@hearing_schedule)
          else
            render_json :unprocessable_entity, 'Failed to Delete Schedule', @hearing_schedule.errors
          end
        end

        def today
          @hearing_schedules = policy_scope(current_tenant.hearing_schedules_today_approved)
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
        end

        def reminders
          @hearing_schedules = policy_scope(current_tenant.hearing_schedules_reminder)
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
        end

        def pending
          @hearing_schedules = policy_scope(current_tenant.hearing_schedules_pending)
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
        end

        def overdue
          @hearing_schedules = policy_scope(current_tenant.hearing_schedules_overdue)
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
        end

        # fetch all hearing that has been approved with schedules
        # fetch all hearing that has been approved and based on month
        def month
          date_range = parse_month_range(params[:month])
          @hearing_schedules = policy_scope(current_tenant.hearing_schedules
                                                          .where(scheduled_date: date_range)
                                                          .where(schedule_status: 'approved')
                                                          .order(scheduled_date: :asc))
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
        end

        def list
          @hearing_schedules = policy_scope(current_tenant.hearing_schedules
                                                          .order(scheduled_date: :asc))
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
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

        def hearing_schedule_query
          HearingScheduleQuery.new(@hearing)
        end

        def parse_month_range(month_param)
          default_start = Date.current.beginning_of_month
          default_end = Date.current.end_of_month

          return default_start..default_end if month_param.blank?

          begin
            start_date = Date.strptime(month_param, '%Y-%m').beginning_of_month
            end_date = start_date.end_of_month
            start_date..end_date
          rescue ArgumentError
            default_start..default_end
          end
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
          params.expect(hearing_schedule: %i[scheduled_date schedule_status reschedule_reason])
        end
      end
    end
  end
end
