class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable

  # Associations
  has_one :profile, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :authored_contents, class_name: 'Content', foreign_key: 'author_id', dependent: :destroy
  
  has_many :sent_match_requests, class_name: 'MatchRequest', 
           foreign_key: 'sender_id', dependent: :destroy
  has_many :received_match_requests, class_name: 'MatchRequest', 
           foreign_key: 'receiver_id', dependent: :destroy
  
  has_many :matches_as_user1, class_name: 'Match', foreign_key: 'user1_id', dependent: :destroy
  has_many :matches_as_user2, class_name: 'Match', foreign_key: 'user2_id', dependent: :destroy
  
  has_many :notifications, dependent: :destroy
  has_many :analytics_events, dependent: :destroy
  
  has_and_belongs_to_many :roles

  # Validations
  validates :email, presence: true, uniqueness: true, 
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, 
            format: { 
              with: /\A(?=.*[a-zA-Z])(?=.*\d)(?=.*[@$!%*?&])/,
              message: "は英数字と記号を含める必要があります" 
            },
            if: :password_required?

  # Callbacks
  after_create :create_default_profile
  after_create :assign_default_role

  # Scopes
  scope :active, -> { where(locked_at: nil) }
  scope :admins, -> { joins(:roles).where(roles: { name: 'admin' }) }

  # Methods
  def admin?
    roles.exists?(name: 'admin')
  end

  def matches
    Match.where('user1_id = ? OR user2_id = ?', id, id)
  end

  private

  def create_default_profile
    create_profile! unless profile
  end

  def assign_default_role
    default_role = Role.find_or_create_by(name: 'user') do |role|
      role.description = '一般ユーザー'
    end
    roles << default_role unless roles.any?
  end
end
