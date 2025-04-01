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
            binding.pry
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

        def notify_hearing_created(hearing)
          schedule = hearing.hearing_schedules.last
          recipients = notification_recipients

          HearingNotifier.with(
            record: hearing,
            message: 'New Hearing Created',
            hearing: hearing,
            hearing_schedule: schedule,
            case: @case
          ).deliver(recipients)
        end

        def notification_recipients
          # Get the single judge for this case
          judge = @case.case_participants.joins(user: :roles)
                       .find_by(roles: { name: 'Judge' })
                    &.user

          binding.pry
          # Get tenant admins
          admins = current_tenant.users.with_role(:admin, current_tenant)

          # Return array with judge (if found) and admins
          [judge, *admins].compact
        end

        def hearing_params
          params.expect(
            hearing: [:hearing_type_id, :hearing_status,
                      { hearing_schedules_attributes: %i[id scheduled_date schedule_status
                                                         reschedule_reason author _destroy] }]
          )
        end
      end
    end
  end
end
