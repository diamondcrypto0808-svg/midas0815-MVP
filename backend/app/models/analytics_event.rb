class AnalyticsEvent < ApplicationRecord
  belongs_to :user, optional: true

  # Validations
  validates :event_type, presence: true
  validates :event_category, presence: true

  # Scopes
  scope :by_type, ->(type) { where(event_type: type) }
  scope :by_category, ->(category) { where(event_category: category) }
  scope :in_date_range, ->(start_date, end_date) { 
    where(created_at: start_date..end_date) 
  }
end
