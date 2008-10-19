class SessionsController < ApplicationController
  include LoginActions

  def new
    @user_login = UserLogin.new
  end

  def create
    logout_keeping_session!
    load_user_login
    if @user_login.valid?
      if @user_login.openid_attempt?
        begin_openid :openid_identifier => @user_login.identity_url, :openid_params => {:user_login => params[:user_login].to_param}
      elsif @user_login.email_attempt?
        login_and_remember(@user_login.user)
        redirect_to root_url
      end
    else
      render :action => 'new'
    end
  end

  def complete
    complete_openid do |result, identity_url, registration|
      load_user_login
      if result.successful?
        @user = User.find_or_initialize_by_identity_url(identity_url)
        complete_openid_for_new_user if @user.new_record?
        login_and_remember(@user)
        if @user.active?
          redirect_to root_path
        else
          redirect_to edit_user_path(@user, :openid_registration => {:user => simple_registration_attributes(registration)})
        end
      else
        flash[:error] = result.message || "Sorry, open id authentication failed."
        redirect_to(new_session_url)
      end
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

  def email
    @user_login = UserLogin.new
  end

  protected

  def complete_openid_for_new_user
    @user.save_without_validation
    @user.register_with_openid!
  end

  def load_user_login
    @user_login = UserLogin.new params[:user_login]
  end

  def login_and_remember(user)
    user.remember_me if @user_login.wants_to_be_remembered?
    successful_login_for(user)
  end

  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:email]}'"
    logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  def simple_registration_attributes(registration)
   first_name, last_name = registration['fullname'].split(" ", 2) if registration['fullname']
    {
      :email => registration[:email],
      :first_name => first_name,
      :last_name => last_name
    }
  end

end

