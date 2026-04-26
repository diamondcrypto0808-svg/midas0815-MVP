class MatchRequest < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  # Enums
  enum status: { pending: 0, accepted: 1, rejected: 2 }

  # Validations
  validates :sender_id, uniqueness: { 
    scope: [:receiver_id, :status], 
    conditions: -> { where(status: :pending) },
    message: "は既にリクエストを送信しています" 
  }
  validate :users_must_be_different

  # Callbacks
  after_create :notify_receiver
  after_update :handle_status_change, if: :saved_change_to_status?

  # Scopes
  scope :pending, -> { where(status: :pending) }

  private

  def users_must_be_different
    if sender_id == receiver_id
      errors.add(:base, "自分自身にリクエストを送信できません")
    end
  end

  def notify_receiver
    Notification.create!(
      user: receiver,
      notification_type: 'match_request',
      title: 'マッチングリクエストが届きました',
      message: "#{sender.profile&.display_name || sender.email}さんからマッチングリクエストが届きました",
      data: { match_request_id: id, sender_id: sender_id }
    )
  end

  def handle_status_change
    if accepted?
      create_match
      notify_sender_accepted
    elsif rejected?
      notify_sender_rejected
    end
  end

  def create_match
    # Calculate similarity score
    similarity = Matching::SimilarityCalculator.new(
      sender.profile, 
      receiver.profile
    ).calculate

    Match.create!(
      user1_id: sender_id,
      user2_id: receiver_id,
      similarity_score: similarity,
      matched_at: Time.current
    )
  end

  def notify_sender_accepted
    Notification.create!(
      user: sender,
      notification_type: 'match_request_accepted',
      title: 'マッチングリクエストが承認されました',
      message: "#{receiver.profile&.display_name || receiver.email}さんがあなたのリクエストを承認しました",
      data: { match_request_id: id, receiver_id: receiver_id }
    )
  end

  def notify_sender_rejected
    Notification.create!(
      user: sender,
      notification_type: 'match_request_rejected',
      title: 'マッチングリクエストが拒否されました',
      message: 'あなたのリクエストは拒否されました',
      data: { match_request_id: id }
    )
  end
end
