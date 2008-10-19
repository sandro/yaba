require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  describe 'activating an account' do
    describe 'successful activation' do
      before :each do
        @user = stub_model(User, :state => 'email_verification_pending')
        @user.stub!(:activate!)
        User.stub!(:find_by_activation_code).and_return(@user)
      end

      it 'should activate the user account' do
        @user.should_receive(:activate!)
        get :activate
      end

      it 'should inform the user and redirect' do
        get :activate
        flash[:notice].should_not be_nil
        response.should redirect_to(root_path)
      end
    end

    it 'should inform the user when the activation code is invalid' do
      User.stub!(:find_by_activation_code).and_return(nil)
      get :activate
      flash[:error].should_not be_nil
      response.should redirect_to(root_path)
    end
  end

  describe 'creating an account' do
    it 'redirects on success' do
      lambda do
        post :create, :user => Factory.attributes_for(:user)
      end.should change(User, :count).by(1)
      response.should be_redirect
    end

    it 'transitions the state for an email login' do
      user = stub_model(User, :save => true)
      user.should_receive(:register_with_email!)
      User.stub!(:new).and_return(user)
      post :create, :user => Factory.attributes_for(:user)
    end

    it 're-renders the form on failure' do
      lambda do
        post :create, :user => Factory.attributes_for(:user, :password => nil)
      end.should_not change(User, :count)
      assigns[:user].errors.on(:password).should_not be_nil
      response.should render_template(:new)
    end
  end

  describe 'editing a user' do
    before :each do
      @user = login_as_user
      User.stub!(:find).and_return(@user)
    end

    it 'should accept openid registration params' do
      openid_attrs = {:user => {'first_name' => "Joe", 'last_name' => "Bob"}}
      @user.should_receive(:attributes=).with(openid_attrs[:user])
      get :edit, :id => @user.id, :openid_registration => openid_attrs
    end

    it 'should assign the user to the view' do
      get :edit, :id => 1
      assigns[:user].should == @user
    end
  end

  describe 'resetting a password' do
    it 'should assign the user to the view' do
      user = mock(User)
      User.stub!(:find_by_reset_code).and_return(user)
      get :reset
      assigns[:user].should == user
    end

    it 'should redirect and inform the user of an error' do
      User.stub!(:find_by_reset_code).and_return(nil)
      get :reset
      flash[:error].should_not be_nil
      response.should redirect_to(root_path)
    end

    describe 'resetting the password' do
      describe 'found the user by reset code' do
        before :each do
          @user = stub_model(User, :update_attributes => true, :clear_reset_code! => nil)
          User.stub!(:find_by_reset_code).and_return(@user)
        end

        it 'should clear the reset code' do
          @user.should_receive(:clear_reset_code!)
          put :reset_password, :user => {}
        end

        it 'should log the user in, inform then and redirect' do
          controller.should_receive(:current_user=)
          put :reset_password, :user => {}
          flash[:notice].should_not be_nil
          response.should redirect_to(root_path)
        end

      end

      it 'should re-render the form and inform the user of errors' do
        user = stub_model(User)
        User.stub!(:find_by_reset_code).and_return(user)
        put :reset_password, :user => {}
        response.should render_template(:reset)
      end
    end
  end

  describe 'forgetting a password' do
    describe 'found the user' do
      before :each do
        @user = stub_model(User, :make_reset_code! => nil)
        User.stub!(:find_by_email).and_return(@user)
      end
      it 'should create a reset code when a user is found' do
        @user.should_receive(:make_reset_code!)
        put :send_forgotten_password
      end

      it 'should inform the user and redirect after creating a reset code' do
        put :send_forgotten_password
        flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end

    it 'should inform the user when it could not send a forgotten email reset code' do
      User.stub!(:find_by_email).and_return(nil)
      put :send_forgotten_password
      flash[:error].should_not be_nil
      response.should render_template(:forgot_password)
    end
  end

  describe 'updating a user' do
    before :each do
      @user = login_as_user
      User.stub!(:find).and_return(@user)
    end

    describe 'a successful update' do
      before :each do
        @user.stub!(:update_attributes).and_return(true)
      end

      it 'should attempt to activate the user account' do
        @user.should_receive(:activate!)
        put :update, :id => @user.id
      end

      it 'should inform the user of success and redirect' do
        put :update, :id => @user.id
        flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end

    it 'should re-render the form and inform the user when there is an error' do
      put :update, :id => @user.id
      flash[:error].should_not be_nil
      response.should render_template(:edit)
    end
  end
end
