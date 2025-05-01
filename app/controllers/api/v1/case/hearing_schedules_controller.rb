# frozen_string_literal: true

module Api
  module V1
    module Case
      # Hearing Schedule Controller
      # rubocop:disable Metrics/ClassLength
      class HearingSchedulesController < ApplicationController
        before_action :authenticate_user!
        before_action :court_cases
        before_action :case, only: %i[index update destroy]
        before_action :hearing, only: %i[index update destroy]
        before_action :hearing_schedule, only: %i[update destroy]

        def index
          @hearing_schedules = policy_scope(@hearing.hearing_schedules).order(scheduled_date: :asc)
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
        end

        def update
          authorize @hearing_schedule
          if @hearing_schedule.update(hearing_schedules_params)
            Schedules::HearingScheduleService.new(@case, @hearing, @hearing_schedule, current_user).notify
            render_json :ok, 'Schedule Updated Successfully', serialized_hearing_schedule(@hearing_schedule)
          else
            render_json :unprocessable_entity, 'Failed to Update Schedule', @hearing_schedule.errors
          end
        end

        def destroy
          authorize @hearing_schedule
          if @hearing_schedule.destroy
            Schedules::HearingScheduleService.new(@case, @hearing, @hearing_schedule, current_user).notify
            render_json :ok, 'Schedule Deleted Successfully', serialized_hearing_schedule(@hearing_schedule)
          else
            render_json :unprocessable_entity, 'Failed to Delete Schedule', @hearing_schedule.errors
          end
        end

        def today
          @hearing_schedules = policy_scope(
            HearingSchedule.today_approved.for_accessible_courts(current_user.accessible_court_ids)
          )
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
        end

        def reminders
          @hearing_schedules = policy_scope(
            HearingSchedule.reminder.for_accessible_courts(current_user.accessible_court_ids)
          )
          @hearing_schedules = policy_scope(current_tenant.hearing_schedules_reminder)
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
        end

        def pending
          @hearing_schedules = policy_scope(
            HearingSchedule.pending.for_accessible_courts(current_user.accessible_court_ids)
          )
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
        end

        def overdue
          @hearing_schedules = policy_scope(
            HearingSchedule.reminder.for_accessible_courts(current_user.accessible_court_ids)
          )
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
        end

        def month
          date_range = parse_month_range(params[:month])
          @hearing_schedules = policy_scope(
            HearingSchedule.for_accessible_courts(current_user.accessible_court_ids)
                           .where(scheduled_date: date_range).where(schedule_status: 'approved')
                           .order(scheduled_date: :asc)
          )
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
        end

        def list
          @hearing_schedules = policy_scope(
            HearingSchedule
              .for_accessible_courts(current_user.accessible_court_ids)
              .order(scheduled_date: :asc)
          )
          authorize @hearing_schedules
          render_json :ok, nil, serialized_hearing_schedules(@hearing_schedules)
        end

        private

        def court_cases
          @court_cases ||= ::Case.where(court_id: current_user.accessible_court_ids)
                                 .or(::Case.where(bench_id: current_user.accessible_court_ids))
        end

        def case
          @case ||= @court_cases.find_by(id: params[:case_id])
        end

        def hearing
          @hearing ||= @case.hearings.find(params[:hearing_id])
        end

        def hearing_schedule
          @hearing_schedule ||= @hearing.hearing_schedules.find(params[:id])
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
      # rubocop:enable Metrics/ClassLength
    end
  end
end
