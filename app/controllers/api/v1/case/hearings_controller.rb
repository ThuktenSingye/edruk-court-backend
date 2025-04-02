# frozen_string_literal: true

module Api
  module V1
    module Case
      # Hearing Controller
      class HearingsController < ApplicationController
        before_action :authenticate_user!
        before_action :case
        before_action :hearing, only: [:update]

        def index
          @hearings = policy_scope(@case.hearings).includes(:hearing_type, :hearing_schedules)
          authorize @hearings
          render_json :ok, nil, serialized_hearings(@hearings)
        end

        def create
          @hearing = @case.hearings.build(hearing_params)

          authorize @hearing
          if @hearing.save
            notify_hearing_created(@hearing)
            render_json :created, 'Hearing created Successfully', serialized_hearing(@hearing)
          else
            render_json :unprocessable_entity, nil, @hearing.errors
          end
        end

        def update
          authorize @hearing
          if @hearing.update(hearing_params)
            render_json :ok, 'Hearing Updated', serialized_hearing(@hearing)
          else
            render_json :unprocessable_entity, nil, @hearing.errors
          end
        end

        def case
          @case ||= current_tenant.cases.find(params[:case_id])
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

        # constraint
        # when creating miscellaneous hearing, check if bench exist
        # if bench exist, assign the case, schedule and notify the judge
        # if bench does not exist, default judge and notify the judge

        # when creating preliminar hearing, check if bench exist
        # if bench exist, assign the case to bench and bench clerk
        # if bench does not then default judge and select bench clerk
        # notify the user

        # for the rest of the hearing, when hearing is created along with schedule, notify the participant.

        # need method ot check if bench exisit
        # need method to check type of prelimninary
        # need method to assign the case to bench and clekr
        #
        def notify_hearing_created(hearing)
          schedule = hearing.hearing_schedules.last
          recipient = notification_recipient

          return unless recipient

          params = {
            record: hearing,
            message: 'new_hearing',
            hearing: hearing,
            hearing_schedule: schedule,
            case: @case
          }
          notification = HearingNotifier.with(params).deliver(recipient)

          if notification.persisted?
            Rails.logger.info "Hearing notification delivered to #{recipient.email}"
            true
          else
            Rails.logger.error "Failed to deliver hearing notification to #{recipient.email}"
            false
          end
        end

        def notification_recipient
          # Get the single judge for this case
          @case.case_participants.joins(user: :roles)
               .find_by(roles: { name: 'Judge' })
               &.user
        end

        def hearing_params
          params.expect(
            hearing: [:hearing_type_id,
                      :hearing_status, :case_id,
                      { hearing_schedules_attributes: [
                        :id,
                        :scheduled_date,
                        :schedule_status,
                        :reschedule_reason,
                        :scheduled_by_id, # Changed to match your database column
                        :_destroy
                      ] }]
          )
        end
      end
    end
  end
end
