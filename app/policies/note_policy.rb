# frozen_string_literal: true

# Note Policy Class
class NotePolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5
  delegate :hearing, to: :record
  delegate :hearing_type, to: :hearing, allow_nil: true
  delegate :name, to: :hearing_type, prefix: true, allow_nil: true
  delegate :case, to: :hearing, allow_nil: true
  delegate :court_id, to: :case, prefix: true, allow_nil: true
  delegate :case_participants, to: :case, prefix: true, allow_nil: true

  # Policy Scope
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.registrar?
        registrar_notes
      elsif user.judge? || user.clerk?
        assigned_case_notes
      else
        scope.where(user_id: user.id)
      end
    end

    private

    def registrar_notes
      scope.joins(hearing: :case)
           .where(cases: { court_id: user.court_id })
           .where(user_id: user.id)
    end

    def assigned_case_notes
      scope.joins(hearing: { case: :case_participants })
           .where(case_participants: { user_id: user.id })
           .where(user_id: user.id)
    end
  end

  def index?
    user.admin? || user.judge? || user.registrar? || user.clerk?
  end

  def create?
    court_user? && (registrar_creates_notes? || judge_or_clerk_creates_notes?)
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  private

  def registrar_creates_notes?
    user.registrar? && pre_hearing?
  end

  def judge_or_clerk_creates_notes?
    assigned_to_judge? || (assigned_to_clerk? && !pre_hearing?)
  end

  def pre_hearing?
    miscellaneous_hearing?
  end

  def preliminary_hearing?
    hearing_type_name&.casecmp?('preliminary')
  end

  def miscellaneous_hearing?
    hearing_type_name&.casecmp?('miscellaneous')
  end

  def assigned_to_judge?
    user.judge? && participant_exists_as?('Judge')
  end

  def assigned_to_clerk?
    user.clerk? && participant_exists_as?('Clerk')
  end

  def participant_exists_as?(role_name)
    case_case_participants&.exists?(
      user: user,
      role: Role.where(name: role_name)
    )
  end

  def court_user?
    user.court_id == case_court_id
  end
end
