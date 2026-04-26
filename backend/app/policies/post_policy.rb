class PostPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present?
  end

  def update?
    user.present? && (record.user_id == user.id || user.admin?)
  end

  def destroy?
    user.present? && (record.user_id == user.id || user.admin?)
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
