# frozen_string_literal: true

# Case Policy Scope
class CasePolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  def index?
    user.admin? || user.registrar? || user.judge? || user.clerk?
  end

  def show?
    user.present? && court_user?
  end

  def update?
    user.registrar? || user.clerk?
  end

  def create?
    user.registrar?
  end

  def statistics?
    user.admin? || user.registrar? || user.judge? || user.clerk?
  end

  # Case Scope
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin? || user.registrar?
        scope.all
      else
        cases_assigned_to_user
      end
    end
  end

  private

  def judge_and_clerk_role_ids
    @judge_and_clerk_role_ids ||= Role.where(name: %w[Judge Clerk]).pluck(:id)
  end

  def cases_assigned_to_user
    scope.joins(:case_participants)
         .where(case_participants: {
                  user: user,
                  role_id: @judge_and_clerk_role_ids
                })
  end

  def court_user?
    user.court_id == record.court_id
  end
end
