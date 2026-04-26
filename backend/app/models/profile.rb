class Profile < ApplicationRecord
  belongs_to :user

  # Active Storage
  has_one_attached :avatar

  # Validations
  validates :display_name, length: { maximum: 50 }, allow_blank: true
  validates :bio, length: { maximum: 500 }, allow_blank: true

  # Methods
  def avatar_url
    if avatar.attached?
      Rails.application.routes.url_helpers.rails_blob_url(avatar, only_path: true)
    else
      nil
    end
  end

  def interests_list
    interests || []
  end

  def skills_list
    skills || []
  end

  def preferences_hash
    preferences || {}
  end
end
