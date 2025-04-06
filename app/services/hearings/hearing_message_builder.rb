# frozen_string_literal: true

# Hearing Message Builder
class HearingMessageBuilder
  def initialize(params)
    @message_type = params[:message_type]
    @hearing_type = params[:hearing_type] || 'Hearing'
    @case_id = params[:case_id] || 'N/A'
    @scheduled_date = params[:scheduled_date]
    @new_scheduled_date = params[:new_scheduled_date]
    @schedule_status = params[:schedule_status] || 'pending'
  end

  def build
    case @message_type.to_s
    when 'pre_hearing' then pre_hearing_message
    when 'post_hearing' then post_hearing_message
    when 'hearing_update' then status_update_message
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
    case @schedule_status.to_sym
    when :approved then approved_message
    when :rescheduled then rescheduled_message
    when :cancelled then cancelled_message
    when :pending then pending_review_message
    else generic_status_message
    end
  end

  def approved_message
    "#{@hearing_type} hearing for Case #{@case_id} confirmed for #{formatted_date(@scheduled_date)}."
  end

  def rescheduled_message
    date = @new_scheduled_date || @scheduled_date
    "#{@hearing_type} hearing for Case #{@case_id} rescheduled to #{formatted_date(date)}."
  end

  def cancelled_message
    "#{@hearing_type} hearing for Case #{@case_id} has been cancelled."
  end

  def pending_review_message
    "#{@hearing_type} hearing for Case #{@case_id} requires your review."
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
