module LoginActions

  private
  def successful_login_for(user)
    # Protects against session fixation attacks, causes request forgery
    # protection if user resubmits an earlier form using back
    # button. Uncomment if you understand the tradeoffs.
    # reset_session
    self.current_user = user
    handle_remember_cookie! @user_login.wants_to_be_remembered?
    flash[:notice] = "Logged in successfully"
  end
end
