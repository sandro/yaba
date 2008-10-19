class UserLogin 
  include Validateable

  attr_accessor :identity_url, :email, :password, :remember_me
  attr_reader :user

  validates_presence_of :identity_url, :if => lambda {|s| s.openid_attempt?}
  validates_presence_of :email, :password, :if => lambda {|s| s.email_attempt?}

  validate :login_attempted
  validate :user_authenticated, :if => lambda {|s| s.email_attempt?}

  def initialize(args=nil)
    args.each {|k,v| instance_variable_set("@#{k}", v)} if args
  end

  def attempt
    return nil if identity_url.nil? && email.nil? && password.nil?
    identity_url.nil? ? :email : :openid
  end

  def email_attempt?
    attempt == :email
  end

  def openid_attempt?
    attempt == :openid
  end

  def to_hash
    Hash[*instance_values.map{|k,v| [k.to_sym, v]}.flatten]
  end

  def wants_to_be_remembered?
    remember_me == "1"
  end

  private

  def login_attempted
    errors.add_to_base("Login should contain an e-mail or open id url") unless attempt
  end

  def user_authenticated
    @user = User.authenticate(email, password)
    errors.add_to_base("Could not authenticate your email and password") unless @user
  end
end

