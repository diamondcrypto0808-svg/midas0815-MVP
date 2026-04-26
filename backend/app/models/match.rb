class Match < ApplicationRecord
  belongs_to :user1, class_name: 'User'
  belongs_to :user2, class_name: 'User'

  # Validations
  validates :user1_id, uniqueness: { scope: :user2_id }
  validates :similarity_score, presence: true, 
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validate :users_must_be_different

  # Callbacks
  after_create :notify_users

  # Scopes
  scope :for_user, ->(user_id) {
    where('user1_id = ? OR user2_id = ?', user_id, user_id)
  }

  # Methods
  def other_user(current_user)
    current_user.id == user1_id ? user2 : user1
  end

  private

  def users_must_be_different
    if user1_id == user2_id
      errors.add(:base, "同じユーザー同士はマッチできません")
    end
  end

  def notify_users
    [user1, user2].each do |user|
      Notification.create!(
        user: user,
        notification_type: 'match_established',
        title: '新しいマッチが成立しました',
        message: 'あなたに適したユーザーとマッチしました',
        data: { match_id: id }
      )
    end
  end
end
