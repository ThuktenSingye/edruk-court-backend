# frozen_string_literal: true

# Case Document Policy
class CaseDocumentPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  delegate :hearing, to: :record, allow_nil: true
  delegate :hearing_type, to: :hearing, allow_nil: true
  delegate :name, to: :hearing_type, prefix: true, allow_nil: true
  delegate :case, to: :hearing, allow_nil: true
  delegate :court_id, to: :case, prefix: true, allow_nil: true
  delegate :case_participants, to: :case, prefix: true, allow_nil: true

  # Case Document Index Scope Class
  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if user.registrar?
        registrar_documents
      elsif user.judge?
        docs_assigned_to_judge.post_hearing.where(document_status: 'verified')
      elsif user.clerk?
        docs_assigned_to_clerk.post_hearing
      else
        user_cases
      end
    end

    private

    def registrar_documents
      scope.joins(hearing: :case)
           .where(cases: { court_id: user.court_id })
    end

    def docs_assigned_to_judge
      scope.joins(hearing: { case: :case_participants })
           .where(case_participants: { user_id: user.id, role: Role.find_by(name: 'Judge') })
    end

    def docs_assigned_to_clerk
      scope.joins(hearing: { case: :case_participants })
           .where(case_participants: { user_id: user.id, role: Role.find_by(name: 'Clerk') })
    end

    def user_cases
      scope.joins(hearing: { case: :case_participants })
           .where(case_participants: {
                    user: user,
                    role_id: user_roles_ids
                  })
    end

    def user_roles_ids
      Role.where(name: %w[Defendant Plaintiff Lawyer Prosecutor]).pluck(:id)
    end
  end

  def index?
    true
  end

  def create?
    registrar_creates_documents? || judge_or_clerk_creates_documents? ||
      plaintiff_cases? || defendant_cases?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  def sign?
    create?
  end

  def sign_all?
    index?
  end

  private

  def registrar_creates_documents?
    user.registrar? && pre_hearing?
  end

  def judge_or_clerk_creates_documents?
    (assigned_to_judge? || assigned_to_clerk?) && !pre_hearing?
  end

  def pre_hearing?
    hearing_type_name&.casecmp?('miscellaneous')
  end

  def assigned_to_judge?
    user.judge? && involved_in_case?('Judge')
  end

  def assigned_to_clerk?
    # user.clerk? && involved_in_case?('Clerk')
    user.clerk? && participant_exists_as?('Clerk')
  end

  def participant_exists_as?(role_name)
    case_case_participants&.exists?(
      user: user,
      role: Role.where(name: role_name)
    )
  end

  def involved_in_case?(roles)
    return false if user.blank?

    participant_role_ids = Role.where(name: roles).pluck(:id)
    case_case_participants.where(user: user, role_id: participant_role_ids).any?
  end

  def plaintiff_cases?
    involved_in_case?(%w[Plaintiff Lawyer Prosecutor])
  end

  def defendant_cases?
    involved_in_case?('Defendant')
  end

  def court_user?
    user.court_id == case_court_id
  end
end
