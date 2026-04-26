class MatchRequestPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def update?
    user.present? && record.receiver_id == user.id
  end

  class Scope < Scope
    def resolve
      scope.where('sender_id = ? OR receiver_id = ?', user.id, user.id)
    end
  end
end
