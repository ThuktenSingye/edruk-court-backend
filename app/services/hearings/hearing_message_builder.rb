# frozen_string_literal: true

module Hearings
  # Hearing Message Builder
  class HearingMessageBuilder
    # :message, :case, :hearing, :hearing_schedule
    def initialize(params)
      @message_type = params[:message_type]
      @hearing_type = params[:hearing_type] || 'Hearing'
      @case_id = params[:case_id] || 'N/A'
      @scheduled_date = params[:scheduled_date]
      @hearing_status = params[:hearing_status] || 'ongoing'
    end

    def build
      Rails.logger.info "✅ Authenticated user #{@message_type}"
      case @message_type

      when :pre_hearing then pre_hearing_message
      when :post_hearing then post_hearing_message
      when :hearing_update then status_update_message
      else default_message
      end
    end

    private

    def pre_hearing_message
      "Case #{@case_id} is assigned to you. Please approve or reject."
    end

    def post_hearing_message
      "New #{@hearing_type} hearing for Case #{@case_id} scheduled at #{formatted_date(@scheduled_date)}. " \
        'Please approve or request reschedule.'
    end

    def status_update_message
      case @hearing_status.to_sym
      when :ongoing then ongoing_message
      when :completed then completed_message
      when :pending then pending_review_message
      when :dismissed then cancelled_message
      else generic_status_message
      end
    end

    def ongoing_message
      "Ongoing #{@hearing_type} hearing for Case #{@case_id}."
    end

    def completed_message
      "#{@hearing_type} hearing for Case #{@case_id} is Completed on #{@scheduled_date}."
    end

    def cancelled_message
      "#{@hearing_type} hearing for Case #{@case_id} has been cancelled."
    end

    def pending_review_message
      "#{@hearing_type} hearing for Case #{@case_id} is on pending."
    end

    def generic_status_message
      "Status updated for #{@hearing_type} hearing (Case #{@case_id})"
    end

    def default_message
      "Notification regarding Case #{@case_id}"
    end

    def formatted_date(date)
      date&.strftime('%Y-%m-%d %H:%M:%S') || 'a future date'
    end
  end
end
