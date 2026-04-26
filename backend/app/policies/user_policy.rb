class UserPolicy < ApplicationPolicy
  def show?
    true # Anyone can view user profiles
  end

  def update?
    user.present? && (record.id == user.id || user.admin?)
  end

  def profile?
    show?
  end

  def update_profile?
    update?
  end

  def upload_avatar?
    update?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
