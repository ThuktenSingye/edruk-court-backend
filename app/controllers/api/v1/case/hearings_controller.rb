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
        before_action :assign_sequence_number, only: [:create]

        def index
          @hearings = policy_scope(@case.hearings.includes(:hearing_type, :hearing_schedules))
          authorize @hearings
          render_json :ok, nil, serialized_hearings(@hearings)
        end

        def create
          final_params = assign_scheduler(hearing_params)
          @hearing = @case.hearings.build(final_params.except(:bench_id, :judge_id, :clerk_id))
          # update the schedule and hearing status to complete
          authorize @hearing
          ActiveRecord::Base.transaction do
            last_hearing = @case.hearings.last
            last_hearing.update!(hearing_status: 'completed') if last_hearing.present?

            @hearing.save!
          end

          Hearings::HearingService.new(@case, @hearing, hearing_params, current_user).create_and_notify
          render_json :created, 'Hearing created Successfully', serialized_hearing(@hearing)

          rescue ActiveRecord::RecordInvalid => e
            render_json :unprocessable_entity, nil, e.record.errors
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
          hearings.map do |hearing|
            HearingSerializer.new(hearing, params: { current_user: current_user }).serializable_hash[:data][:attributes]
          end
        end

        def serialized_hearing(hearing)
          HearingSerializer.new(hearing, params: { current_user: current_user }).serializable_hash[:data][:attributes]
        end

        def assign_sequence_number
          return unless rebuttal_hearing?

          rebuttal_type_id = params[:hearing][:hearing_type_id]
          last_seq = @case.hearings.where(hearing_type_id: rebuttal_type_id)
                          .maximum(:sequence_number) || 0
          params[:hearing][:sequence_number] = last_seq + 1
        end

        def rebuttal_hearing?
          rebuttal_type = HearingType.find_by(name: 'Rebuttal')
          params[:hearing][:hearing_type_id].to_i == rebuttal_type.id
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
