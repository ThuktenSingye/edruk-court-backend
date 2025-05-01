# frozen_string_literal: true

# Hearing Schedules Policy
class HearingSchedulePolicy < ApplicationPolicy
  # Hearing Policy Index Scope
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope_for_court_staff if court_staff_user?
      return scope_for_case_participants if case_participant_user?

      scope.none
    end

    private

    def court_staff_user?
      user.registrar? || user.admin? || user.judge? || user.clerk?
    end

    def case_participant_user?
      user.plaintiff? || user.defendant?
    end

    def scope_for_court_staff
      if user.judge? || user.clerk?
        participant_scope_if_needed
      else
        scope.joins(hearing: :case)
             .where(cases: { court_id: user.court_id })
      end
    end

    def scope_for_case_participants
      scope.joins(hearing: { case: :case_participants })
           .where(case_participants: { user_id: user.id })
    end

    def participant_scope_if_needed
      return scope.all unless user.judge? || user.clerk?

      scope.joins(hearing: { case: :case_participants })
           .where(case_participants: { user_id: user.id })
    end
  end

  def index?
    true
  end

  def today?
    true
  end

  def pending?
    true
  end

  def overdue?
    true
  end

  def reminders?
    true
  end

  def month?
    true
  end

  def list?
    true
  end

  def update?
    # court_user? && authorized_for_update?
    authorized_for_update?
  end

  def destroy?
    court_user? && authorized_for_destroy?
  end

  private

  def authorized_user?
    user.registrar? || user.clerk? || user.admin? ||
      user.judge? || user.plaintiff? || user.defendant?
  end

  def authorized_for_update?
    first_hearing? ? user.registrar? : assigned_to_judge? || assigned_to_clerk?
  end

  def authorized_for_destroy?
    first_hearing? ? user.registrar? : assigned_to_clerk?
  end

  def first_hearing?
    miscellaneous_hearing?
  end

  def miscellaneous_hearing?
    record.hearing.hearing_type.name&.casecmp?('miscellaneous')
  end

  def assigned_to_judge?
    user.judge? && case_participant_with_role?('Judge')
  end

  def assigned_to_clerk?
    user.clerk? && case_participant_with_role?('Clerk')
  end

  def case_participant_with_role?(role_name)
    record.hearing.case.case_participants.exists?(
      user: user,
      role: Role.where(name: role_name)
    )
  end

  def court_user?
    user.court_id == record.hearing.case.court_id
  end
end
