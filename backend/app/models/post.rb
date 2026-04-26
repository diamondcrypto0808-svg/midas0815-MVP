class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  # Validations
  validates :content, presence: true, length: { maximum: 3000 }

  # Callbacks
  after_create_commit :broadcast_to_timeline

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { order(likes_count: :desc) }

  # Methods
  def liked_by?(user)
    return false unless user
    likes.exists?(user: user)
  end

  private

  def broadcast_to_timeline
    # WebSocket broadcast will be implemented with Action Cable
  end
end
