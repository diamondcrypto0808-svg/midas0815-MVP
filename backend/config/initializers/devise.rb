Devise.setup do |config|
  config.mailer_sender = ENV.fetch('MAILER_SENDER', 'noreply@business-platform.com')
  
  require 'devise/orm/active_record'

  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth, :token_auth]
  
  config.stretches = Rails.env.test? ? 1 : 12
  
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  
  config.password_length = 8..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
  
  # Lockable
  config.lock_strategy = :failed_attempts
  config.unlock_strategy = :time
  config.maximum_attempts = 5
  config.unlock_in = 1.hour
  
  # Timeout
  config.timeout_in = 30.minutes
end
