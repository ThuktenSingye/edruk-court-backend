# frozen_string_literal: true

# Hearing Policy
class HearingPolicy < ApplicationPolicy
  # Hearing Policy Scope
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.registrar?
        scope.joins(:case).where(cases: { court_id: user.court_id })
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
      scope.joins(case: :case_participants)
           .where(case_participants: {
                    user: user,
                    role_id: user_roles_ids
                  })
    end

    def cases_assigned_to_court
      scope.joins(case: :case_participants)
           .where(case_participants: {
                    user: user,
                    role_id: judge_and_clerk_role_ids
                  })
    end
  end

  def index?
    true
  end

  def create?
    registrar_creates_hearing? || judge_or_clerk_creates_hearing?
  end

  def update?
    first_hearing? ? user.registrar? : assigned_to_judge? || assigned_to_clerk?
  end 

  def judgement?
    user.clerk?
  end

  private

  def registrar_creates_hearing?
    user.registrar? && (first_hearing? || miscellaneous_hearing?)
  end

  def judge_or_clerk_creates_hearing?
    (assigned_to_judge? || assigned_to_clerk?) && !first_hearing? && !miscellaneous_hearing?
  end

  def first_hearing?
    no_existing_hearings? || miscellaneous_hearing? || preliminary_hearing?
  end

  def no_existing_hearings?
    record.case.hearings.empty?
  end

  def preliminary_hearing?
    record.hearing_type.name&.casecmp?('preliminary')
  end

  def miscellaneous_hearing?
    record.hearing_type.name&.casecmp?('miscellaneous')
  end

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
