class Notification < ApplicationRecord
  belongs_to :user

  # Validations
  validates :notification_type, presence: true
  validates :title, presence: true

  # Scopes
  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def mark_as_read!
    update!(read: true, read_at: Time.current)
  end
end
