# frozen_string_literal: true

# Profile Policy
class ProfilePolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5
  def show?
    user_profile? || user.role?('Admin')
  end

  def update?
    user_profile? || user.role?('Admin')
  end

  private

  def user_profile?
    record&.user == user
  end
end
