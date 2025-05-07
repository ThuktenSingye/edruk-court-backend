# frozen_string_literal: true

# Court Order Policy Class
class CourtOrderPolicy < ApplicationPolicy
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

  def sent?
    user.registrar? || user.judge? || user.clerk? || user.admin?
  end

  def received?
    sent? || user.user?
  end

  def show?
    sent?
  end

  def create?
    sent?
  end
end
