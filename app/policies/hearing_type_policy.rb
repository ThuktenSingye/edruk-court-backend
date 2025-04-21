# frozen_string_literal: true

# Hearing Type Policy Class
class HearingTypePolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  # Hearing Type Scope
  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if user.registrar?
        scope.where(name: %w[Miscellaneous Preliminary])
      elsif user.clerk? || user.judge?
        scope.where.not(name: %w[Miscellaneous Preliminary])
      else
        scope.none
      end
    end
  end

  def index?
    user.registrar? || user.judge? || user.clerk?
  end

  private

  def pre_hearing?
    record&.name&.casecmp?('miscellaneous')
  end
end
