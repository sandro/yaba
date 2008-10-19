class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "http://#{APP_URL}/users/activate?activation_code=#{user.activation_code}"
  end

  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://#{APP_URL}/"
  end

  def reset_password(user)
    setup_email(user)
    @subject    += 'Did you forget your password?'
    @body[:url]  = "http://#{APP_URL}/users/reset?reset_code=#{user.reset_code}"
  end

  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = ADMIN_EMAIL
    @subject     = "[#{APP_URL}] "
    @sent_on     = Time.now
    @body[:user] = user
  end
end
