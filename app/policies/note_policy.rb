class NotePolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def create?
    court_user? && (registrar_creates_hearing? || judge_or_clerk_creates_hearing?)
  end

  def update?

  end

  def destroy?

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
    record.hearing.case.hearings.empty?
  end

  def preliminary_hearing?
    record.hearing.hearing_type.name&.casecmp?('preliminary')
  end

  def miscellaneous_hearing?
    record.hearing.hearing_type.name&.casecmp?('miscellaneous')
  end

  def assigned_to_judge?
    user.judge? && record.hearing.case.case_participants.exists?(user: user, role: Role.where(name: 'Judge'))
  end

  def assigned_to_clerk?
    user.clerk? && record.hearing.case.case_participants.exists?(user: user, role: Role.where(name: 'Clerk'))
  end

  def court_user?
    user.court_id == record.hearing.case.court_id
  end
end
