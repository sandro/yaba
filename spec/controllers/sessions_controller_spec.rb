require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do
  it 'should set a new user_login' do
    login = UserLogin.new
    UserLogin.should_receive(:new).and_return(login)
    get :new
    assigns[:user_login].should == login
  end

  describe 'logging out' do
    before :each do
      login_with Factory(:user)
    end

    it 'should clear the session' do
      lambda do
        delete :destroy
      end.should change{session[:user_id]}.to(nil)
    end

    it 'should logout killing the session' do
      controller.should_receive(:logout_killing_session!)
      delete :destroy
    end

    it 'should inform the user of a successful logout and redirect' do
      delete :destroy
      flash[:notice].should_not be_nil
      response.should redirect_to(root_url)
    end
  end

  describe "creating a session" do
    before :each do
      controller.stub!(:logout_keeping_session!)
      @login = stub_model(UserLogin)
      UserLogin.stub!(:new).and_return(@login)
    end

    it 'should re-render the form when the login is invalid' do
      @login.stub!(:valid?).and_return(false)
      post :create
      response.should render_template(:new)
    end

    describe 'using email' do
      it 'should log the user in' do
        @login.stub!(:valid?).and_return(true)
        @login.stub!(:email_attempt?).and_return(true)
        controller.should_receive(:successful_login_for)
        post :create, :user_login => {}
      end
    end

    describe 'using openid' do
      it 'should begin the openid login process' do
        @login.stub!(:valid?).and_return(true)
        @login.stub!(:openid_attempt?).and_return(true)
        controller.should_receive(:begin_openid)
        post :create, :user_login => {}
      end
    end
  end

  describe 'completing the openid process' do
    before :each do
      @login = stub_model(UserLogin)
      UserLogin.stub!(:new).and_return(@login)
      @result = mock(:result, :successful? => true, :message => nil)
      @registration = {:email => nil, :first_name => nil, :last_name => nil}
      @identity_url = Factory.next(:user_identity_url)
      controller.stub!(:login_and_remember)
    end

    #it 'should redirect and inform a user of an error' do
      #controller.stub!(:complete_openid).and_yield(@result, @identity_url, @registration)
      #@result.stub!(:successful?).and_return(false)
      #get :complete
      #flash[:error].should_not be_nil
      #response.should redirect_to(new_session_url)
    #end

    describe 'successful openid completion' do
      it 'should register new openid users' do
        u = Factory.build :user_with_identity_url
        controller.stub!(:complete_openid).and_yield(@result, u.identity_url, @registration)
        get :complete
        u = User.find_by_identity_url(u.identity_url).should be_openid_verified
      end

      it 'should redirect active users to homepage' do
        user = stub_model(User, :new_record => false, :state => 'active')
        User.stub!(:find_or_initialize_by_identity_url).and_return(user)
        controller.stub!(:complete_openid).and_yield(@result, @identity_url, @registration)
        get :complete
        response.should redirect_to(root_path)
      end

      it 'should redirect inactive users to the registration page' do
        user = stub_model(User, :new_record => false, :state => 'openid_verified')
        User.stub!(:find_or_initialize_by_identity_url).and_return(user)
        controller.stub!(:complete_openid).and_yield(@result, @identity_url, @registration)
        get :complete
        response.should be_redirect
        response.redirected_to =~ %r(users/#{user.id}/edit?)
      end
    end
  end
end
