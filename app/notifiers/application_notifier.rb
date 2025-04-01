# frozen_string_literal: true

class ApplicationNotifier < Noticed::Event
  deliver_by :database
  deliver_by :action_cable

  param :message, :record

  def to_database
    {
      type: self.class.name,
      params: params,
      metadata: {
        created_at: Time.zone.now,
        court_id: current_tenant.id
      }
    }
  end

  def to_action_cable
    {
      id: record.id,
      type: self.class.name,
      message: message,
      created_at: Time.zone.now,
      url: url
    }
  end

  def message
    params[:message] || ''
  end

  def url
    '#'
  end

  private

  def current_tenant
    ActsAsTenant.current_tenant
  end
end
