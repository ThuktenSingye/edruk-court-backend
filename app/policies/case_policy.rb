# frozen_string_literal: true

# Case Policy Scope
class CasePolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  def index?
    court_user? && (user.admin? || user.registrar? || assigned_to_clerk? || assigned_to_judge?)
  end

  def show?
    user.present? && court_user?
  end

  def update?
    court_user? && (user.registrar? || assigned_to_clerk?)
  end

  def create?
    court_user? && user.registrar?
  end

  def statistics?
    court_user? && (user.admin? || user.registrar? || assigned_to_judge? || assigned_to_clerk?)
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

  def assigned_to_judge?
    user.judge? && record.case_participants.where(user: user, role: Role.where(name: 'Judge'))
  end

  def assigned_to_clerk?
    user.clerk? && record.case_participants.exists?(user: user, role: Role.where(name: 'Clerk'))
  end

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
