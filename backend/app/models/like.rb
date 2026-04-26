class Like < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user

  validates :user_id, uniqueness: { scope: :post_id, message: "は既にいいねしています" }

  after_create :notify_post_author

  private

  def notify_post_author
    return if post.user_id == user_id

    Notification.create!(
      user: post.user,
      notification_type: 'new_like',
      title: 'いいねがつきました',
      message: "#{user.profile&.display_name || user.email}さんがあなたの投稿にいいねしました",
      data: { post_id: post.id, user_id: user.id }
    )
  end
end
