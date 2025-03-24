# frozen_string_literal: true

# Nil Class Policy
class NilClassPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  def show?
    false
  end

  def update?
    false
  end

  # NilClassPolicy Scope
  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      # Raise an error, return an empty collection, or define your logic
      # Example: Raise an error to prevent scoping nil
      raise Pundit::NotDefinedError, 'Cannot scope NilClass'
      # Or, return an empty collection
      # scope.none
    end
  end
end
