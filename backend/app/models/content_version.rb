class ContentVersion < ApplicationRecord
  belongs_to :content

  validates :version_number, presence: true, 
            uniqueness: { scope: :content_id }
  validates :body, presence: true
end
