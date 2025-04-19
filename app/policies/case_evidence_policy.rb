# frozen_string_literal: true

# Case Evidence Policy Class
class CaseEvidencePolicy < ApplicationPolicy
  delegate :hearing, to: :record, allow_nil: true
  delegate :hearing_type, to: :hearing, allow_nil: true
  delegate :name, to: :hearing_type, prefix: true, allow_nil: true
  delegate :case, to: :hearing, allow_nil: true
  delegate :court_id, to: :case, prefix: true, allow_nil: true
  delegate :case_participants, to: :case, prefix: true, allow_nil: true

  # Case Evidence Index Scope Class
  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if user.registrar?
        registrar_evidences
      elsif user.judge?
        evidence_assigned_to_judge.post_hearing.where(document_status: 'verified')
      elsif user.clerk?
        evidence_assigned_to_clerk.post_hearing
      else
        scope.none
      end
    end

    private

    def registrar_evidences
      scope.joins(hearing: :case)
           .where(cases: { court_id: user.court_id })
    end

    def evidence_assigned_to_judge
      scope.joins(hearing: { case: :case_participants })
           .where(case_participants: { user_id: user.id, role: Role.find_by(name: 'Judge') })
    end

    def evidence_assigned_to_clerk
      scope.joins(hearing: { case: :case_participants })
           .where(case_participants: { user_id: user.id, role: Role.find_by(name: 'Clerk') })
    end
  end

  def index?
    user.judge? || user.clerk? || user.registrar?
  end

  def create?
    court_user? && (registrar_creates_evidences? || judge_or_clerk_creates_evidence?)
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  private

  def registrar_creates_evidences?
    user.registrar? && pre_hearing?
  end

  def judge_or_clerk_creates_evidence?
    (assigned_to_judge? || assigned_to_clerk?) && !pre_hearing?
  end

  def pre_hearing?
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
