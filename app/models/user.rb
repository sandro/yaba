# == Schema Information
# Schema version: 20080806020043
#
# Table name: users
#
#  id                        :integer         not null, primary key
#  first_name                :string(40)
#  last_name                 :string(40)
#  identity_url              :string(255)
#  email                     :string(100)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(40)
#  remember_token_expires_at :datetime
#  state                     :string(255)
#

require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  validates_length_of       :email,         :within => 6..100 #r@a.wk
  validates_length_of       :first_name,    :maximum => 40, :allow_nil => true
  validates_length_of       :last_name,     :maximum => 40, :allow_nil => true

  validates_uniqueness_of   :email,         :case_sensitive => false
  validates_uniqueness_of   :identity_url,  :case_sensitive => false, :allow_nil => true

  validates_presence_of     :email
  validates_format_of       :email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD
  validates_format_of       :first_name, :last_name, :with => RE_NAME_OK,  :message => MSG_NAME_BAD, :allow_nil => true

  before_create :make_activation_code 

  attr_accessible :first_name, :last_name, :password, :password_confirmation

  before_save :normalize_identity_url, :if => lambda{ |u| u.using_openid? && u.identity_url_changed? }

  acts_as_state_machine :initial => :pending
  state :pending
  state :openid_verified
  state :email_verification_pending, :exit => :email_registered
  state :active

  event :register_with_openid do
    transitions :from => :pending, :to => :openid_verified, :guard => lambda{|u| u.using_openid?}
  end

  event :register_with_email do
    transitions :from => :pending, :to => :email_verification_pending, :guard => lambda{|u| not u.using_openid?}
  end

  event :activate do
    transitions :from => [:email_verification_pending, :openid_verified], :to => :active
  end

  def self.authenticate(email, password)
    u = find_by_email(email) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def clear_reset_code!
    self.reset_code = nil
    save(false)
  end

  def display_name
    "#{first_name} #{last_name}"
  end

  def make_reset_code!
    @reset_code_set = true
    self.reset_code = self.class.make_token
    save(false)
  end

  # Returns true if the user has just been activated.
  # Hooked into the observer - reenable
  def recently_activated?
    @activated
  end

  def recently_reset_password?
    @reset_code_set
  end

  def using_openid?
    identity_url
  end

  protected

  def email_registered
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  def make_activation_code
    self.activation_code = self.class.make_token
  end

  def normalize_identity_url
    self.identity_url = OpenidWrapper.normalize_url(identity_url)
  end

  def password_required?
    !using_openid? && (crypted_password.blank? || !password.nil?)
  end

end
