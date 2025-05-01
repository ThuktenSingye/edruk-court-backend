# frozen_string_literal: true

module Api
  module V1
    module Case
      # Hearing Controller
      class HearingsController < ApplicationController
        before_action :authenticate_user!
        before_action :court_cases
        before_action :case
        before_action :hearing, only: [:update]

        def index
          @hearings = policy_scope(@case.hearings.includes(:hearing_type, :hearing_schedules))
          authorize @hearings
          render_json :ok, nil, serialized_hearings(@hearings)
        end

        def create
          final_params = assign_scheduler(hearing_params)
          @hearing = @case.hearings.build(final_params.except(:bench_id, :judge_id, :clerk_id))
          authorize @hearing
          if @hearing.save
            Hearings::HearingService.new(@case, @hearing, hearing_params, current_user).create_and_notify
            render_json :created, 'Hearing created Successfully', serialized_hearing(@hearing)
          else
            render_json :unprocessable_entity, nil, @hearing.errors
          end
        end

        def update
          final_params = assign_scheduler(hearing_params)
          authorize @hearing
          if @hearing.update(final_params.except(:bench_id, :judge_id, :clerk_id))
            Hearings::HearingService.new(@case, @hearing, hearing_params, current_user).notify_on_update
            render_json :ok, 'Hearing Updated', serialized_hearing(@hearing)
          else
            render_json :unprocessable_entity, nil, @hearing.errors
          end
        end

        private

        def court_cases
          @court_cases ||= ::Case
                           .where(court_id: current_user.accessible_court_ids)
                           .or(::Case.where(bench_id: current_user.accessible_court_ids))
        end

        def case
          @case ||= @court_cases.find_by(id: params[:case_id])
        end

        def hearing
          @hearing ||= @case.hearings.find(params[:id])
        end

        def serialized_hearings(hearings)
          hearings.map { |hearing| HearingSerializer.new(hearing).serializable_hash[:data][:attributes] }
        end

        def serialized_hearing(hearing)
          HearingSerializer.new(hearing).serializable_hash[:data][:attributes]
        end

        def assign_scheduler(params)
          return params if params[:hearing_schedules_attributes].blank?

          params[:hearing_schedules_attributes].each do |schedule|
            schedule[:scheduled_by_id] = current_user.id
          end

          params
        end

        # rubocop:disable Rails/StrongParametersExpect
        def hearing_params
          params.require(:hearing).permit(
            :hearing_type_id,
            :hearing_status, :case_id, :bench_id, :clerk_id, :judge_id,
            { hearing_schedules_attributes: %i[
              id scheduled_date schedule_status
              reschedule_reason _destroy
            ] }
          )
          # rubocop:enable Rails/StrongParametersExpect
        end
      end
    end
  end
end
