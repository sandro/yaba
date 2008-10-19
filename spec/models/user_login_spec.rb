require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserLogin do

  it 'should not require an email and password when the identity url is present' do
    login_with_openid.should be_valid
  end

  it 'should not require an identity_url when the email and password is present' do
    User.should_receive(:authenticate).and_return(mock(User))
    login_with_email.should be_valid
  end

  it 'should require an email and password or identity_url' do
    user_login = UserLogin.new
    user_login.should_not be_valid
  end

  describe '#to_hash' do
    it 'should make a hash out of attributes' do
      attrs = {:email => "meh@dodgit.com", :remember_me => "hi"}
      login = UserLogin.new attrs
      login.to_hash.should == attrs
    end
  end

  describe "remembering" do
    it "should want to be remembered" do
      login = UserLogin.new :remember_me => "1"
      login.wants_to_be_remembered?.should be_true
    end

    it "should not want to be remembered" do
      login = UserLogin.new :remember_me => "0"
      login.wants_to_be_remembered?.should be_false
    end
  end

  describe 'authenticating the user' do
    it 'should set the user variable after a valid email login' do
      user = mock(User)
      User.should_receive(:authenticate).and_return(user)
      login = login_with_email
      login.should be_valid
      login.user.should == user
    end

    it 'should be an invalid login if the user could not be authenticated' do
      User.should_receive(:authenticate).and_return(nil)
      login = login_with_email
      login.should_not be_valid
    end
  end

  describe 'type of login' do
    it 'should be an openid login' do
      login = login_with_openid
      login.attempt.should == :openid
      login.openid_attempt?.should be_true
    end

    it 'should be an email login when email is present' do
      login = login_with_email
      login.attempt.should == :email
      login.email_attempt?.should be_true
    end

    it 'should be an email login when password is present' do
      login = UserLogin.new :password => "123123"
      login.attempt.should == :email
    end

    it 'should not understand an empty login attempt' do
      login = UserLogin.new 
      login.attempt.should == nil
    end
  end

  def login_with_openid
    Factory.build :user_login_with_openid
  end

  def login_with_email
    Factory.build :user_login_with_email
  end

end
