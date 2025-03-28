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
        scope.joins(:case).where(case: { court_id: user.court_id })
      else
        scope.none
      end
    end
  end

  def index?
    user.clerk? || user.registrar? || user.judge?
  end

  def create?
    court_user? && (user.registrar? || user.clerk?)
  end

  def update?
    court_user? && (user.judge? || user.registrar? || user.clerk?)
  end

  private

  def court_user?
    user.court_id == record.case.court_id
  end
end
