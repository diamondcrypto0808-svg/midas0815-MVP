class Content < ApplicationRecord
  belongs_to :author, class_name: 'User'
  has_many :content_versions, dependent: :destroy

  # Enums
  enum status: { draft: 0, published: 1, archived: 2 }

  # Validations
  validates :title, presence: true, length: { maximum: 200 }
  validates :slug, presence: true, uniqueness: true
  validates :body, presence: true

  # Callbacks
  before_validation :generate_slug, if: -> { title_changed? && slug.blank? }
  after_update :create_version, if: :body_previously_changed?

  # Scopes
  scope :published, -> { where(status: :published) }
  scope :recent, -> { order(published_at: :desc) }

  # Methods
  def publish!
    update!(status: :published, published_at: Time.current)
  end

  def revert_to_version(version_number)
    version = content_versions.find_by(version_number: version_number)
    return false unless version

    update!(body: version.body)
  end

  private

  def generate_slug
    base_slug = title.parameterize
    slug_candidate = base_slug
    counter = 1

    while Content.exists?(slug: slug_candidate)
      slug_candidate = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = slug_candidate
  end

  def create_version
    content_versions.create!(
      version_number: content_versions.count + 1,
      body: body_before_last_save,
      metadata: { updated_at: updated_at }
    )
  end
end
