# frozen_string_literal: true

# Case Policy Scope
class CasePolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  # Case Scope
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin? || user.registrar?
        scope.where(court_id: user.court_id)
      elsif user.clerk? || user.judge?
        cases_assigned_to_court
      else
        user_cases
      end
    end

    private

    def judge_and_clerk_role_ids
      Role.where(name: %w[Judge Clerk]).pluck(:id)
    end

    def user_roles_ids
      Role.where(name: %w[Defendant Plaintiff Lawyer]).pluck(:id)
    end

    def user_cases
      scope.joins(:case_participants)
           .where(case_participants: {
                    user: user,
                    role_id: user_roles_ids
                  })
    end

    def cases_assigned_to_court
      scope.joins(:case_participants)
           .where(case_participants: {
                    user: user,
                    role_id: judge_and_clerk_role_ids
                  })
    end
  end

  def index?
    true
  end

  def show?
    (user.present? && court_user?) || plaintiff_cases? || defendant_cases?
  end

  def update?
    court_user? && (user.registrar? || assigned_to_clerk?)
  end

  def create?
    (court_user? && user.registrar?) || (user.plaintiff? || user.lawyer? || user.user?)
  end

  def statistics?
    index?
  end

  def files?
    index?
  end

  def active?
    index?
  end

  def sign?
    (court_user? && user.registrar?) || involved_in_case?(['Judge'])
  end

  def sign_all?
    (court_user? && user.registrar?) || involved_in_case?(['Judge'])
  end

  private

  def assigned_to_clerk?
    user.clerk? && record.case_participants.exists?(user: user, role: Role.where(name: 'Clerk'))
  end

  def involved_in_case?(roles)
    return false if user.blank?

    participant_role_ids = Role.where(name: roles).pluck(:id)
    record.case_participants.where(user: user, role_id: participant_role_ids).any?
  end

  def plaintiff_cases?
    involved_in_case?(%w[Plaintiff Lawyer Prosecutor])
  end

  def defendant_cases?
    involved_in_case?('Defendant')
  end

  def court_user?
    user.court_id == record.court_id
  end
end
