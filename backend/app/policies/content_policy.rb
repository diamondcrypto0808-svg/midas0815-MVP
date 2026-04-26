class ContentPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.published? || user&.admin? || record.author_id == user&.id
  end

  def create?
    user.present?
  end

  def update?
    user.present? && (record.author_id == user.id || user.admin?)
  end

  def destroy?
    user.present? && (record.author_id == user.id || user.admin?)
  end

  def publish?
    update?
  end

  def versions?
    update?
  end

  def revert?
    update?
  end

  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.published
      end
    end
  end
end
