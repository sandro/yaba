class UsersController < ApplicationController
  include LoginActions
  before_filter :login_required, :only => [:edit, :update, :destroy]

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code params[:activation_code]
    if user && user.email_verification_pending?
      user.activate!
      self.current_user = @user
      flash[:notice] = "Signup complete!"
      redirect_to root_path
    else
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    @user.email = params[:user][:email]
    if @user.save
      @user.register_with_email!
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
      redirect_back_or_default('/')
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find params[:id]
    if params[:openid_registration]
      @user.attributes = params[:openid_registration][:user] 
      @user.email = params[:openid_registration][:user][:email]
    end
  end

  def new
    @user = User.new
    @user_login = UserLogin.new # needed for the open_id form
  end

  def reset
    @user = User.find_by_reset_code(params[:reset_code])
    unless @user
      flash[:error] = "Couldn't find a user with that reset code"
      redirect_to root_path
    end
  end

  def reset_password
    @user = User.find_by_reset_code(params[:user][:reset_code])
    if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
      @user.clear_reset_code!
      self.current_user = @user
      flash[:notice] = "Password reset successfully for #{@user.email}"
      redirect_back_or_default("/")
    else
      render :action => :reset
    end
  end

  def send_forgotten_password
    user = User.find_by_email(params[:email])
    if user
      user.make_reset_code!
      flash[:notice] = "A password reset link was sent to #{user.email}"
      redirect_back_or_default('/')
    else
      flash.now[:error] = "We couldn't find a user with that email address."
      render :action => :forgot_password
    end
  end

  def update
    @user = User.find params[:id]
    @user.email = params[:user][:email] if @user.using_openid?
    if @user.update_attributes(params[:user])
      @user.activate!
      flash[:notice] = "Account has been updated"
      redirect_to root_url
    else
      flash[:error] = "Account could not be updated"
      render :action => :edit
    end
  end

end
