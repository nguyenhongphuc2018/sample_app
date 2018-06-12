class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :email_downcase
  before_create :create_activation_digest
  validates :name, presence: true, length: {maximum: Settings.username.maximum}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: Settings.email.maximum},
    format: {with: VALID_EMAIL_REGEX},
    uniqueness: {case_sensitive: false}
  has_secure_password
  validates :password, presence: true,
    length: {minimum: Settings.pass.minimum}, allow_nil: true

  # Returns the hash digest of the given string.
  def self.digest string
    cost =  if ActiveModel::SecurePassword.min_cost
              BCrypt::Engine::MIN_COST
            else
              BCrypt::Engine.cost
            end
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated? attribute, token
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def current_user? user
    self == user
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Activates an account.
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    digest = User.digest reset_token
    update_columns reset_digest: digest, reset_sent_at: Time.zone.now
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < Settings.time_limit.hours.ago
  end

  private
  # Converts email to all lower-case.
  def email_downcase
    email.downcase!
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
