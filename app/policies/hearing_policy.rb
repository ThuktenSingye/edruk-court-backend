# frozen_string_literal: true

# Hearing Policy
class HearingPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.court_id.present?
        scope.joins(:case).where(cases: { court_id: user.court_id })
      else
        scope.none
      end
    end
  end

  def index?
    user.registrar? || user.clerk? || user.judge?
  end

  def create?
    court_user? && (user.registrar? || assigned_to_clerk?)
  end

  def update?
    court_user? && (assigned_to_clerk? || user.registrar? || assigned_to_judge?)
  end

  private

  def assigned_to_judge?
    user.judge? && record.case.case_participants.exists?(user: user, role: Role.where(name: 'Judge'))
  end

  def assigned_to_clerk?
    user.clerk? && record.case.case_participants.exists?(user: user, role: Role.where(name: 'Clerk'))
  end

  def court_user?
    user.court_id == record.case.court_id
  end
end
