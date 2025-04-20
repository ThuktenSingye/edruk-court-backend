# frozen_string_literal: true

module Schedules
  # Schedule Message Builder
  class ScheduleMessageBuilder
    def initialize(params)
      @message_type = params[:message_type]
      @hearing_type = params[:hearing_type] || 'Hearing'
      @case_id = params[:case_id] || 'N/A'
      @scheduled_date = params[:scheduled_date]
      @schedule_status = params[:schedule_status] || 'ongoing'
    end

    def build
      case @message_type
      when 'schedule_update' then schedule_update_message
      else default_message
      end
    end

    private

    def schedule_update_message
      case @schedule_status.to_sym
      when :approved then approved_message
      when :changes_requested then changes_requested_message
      when :rescheduled then rescheduled_message
      when :cancelled then cancelled_message
      else generic_status_message
      end
    end

    def approved_message
      "#{@hearing_type} hearing for Case #{@case_id} approved."
    end

    def changes_requested_message
      "#{@hearing_type} hearing for Case #{@case_id} requested changes in hearing date."
    end

    def cancelled_message
      "#{@hearing_type} hearing for Case #{@case_id} has been cancelled."
    end

    def rescheduled_message
      "#{@hearing_type} hearing for Case #{@case_id} is rescheduled on #{formatted_date(@scheduled_date)}. ."
    end

    def generic_status_message
      "Status updated for #{@hearing_type} hearing (Case #{@case_id})"
    end

    def default_message
      "Schedule Notification regarding Case #{@case_id}"
    end

    def formatted_date(date)
      date&.strftime('%Y-%m-%d %H:%M:%S') || 'a future date'
    end
  end
end
