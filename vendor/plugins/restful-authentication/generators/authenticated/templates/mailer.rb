class <%= class_name %>Mailer < ActionMailer::Base
  def signup_notification(<%= file_name %>)
    setup_email(<%= file_name %>)
    @subject    += 'Please activate your new account'
  <% if options[:include_activation] %>
    @body[:url]  = "http://YOURSITE/activate/#{<%= file_name %>.activation_code}"
  <% else %>
    @body[:url]  = "http://YOURSITE/login/" <% end %>
  end
  
  def activation(<%= file_name %>)
    setup_email(<%= file_name %>)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://YOURSITE/"
  end

<% if options[:include_forgot_password] -%>
  def reset_password(<%= file_name %>)
    setup_email(<%= file_name %>)
    @subject    += 'Did you forget your password?'
    @body[:url]  = "http://YOURSITE/reset/#{<%= file_name %>.reset_code}"
  end
<% end -%>

  protected
    def setup_email(<%= file_name %>)
      @recipients  = "#{<%= file_name %>.email}"
      @from        = "ADMINEMAIL"
      @subject     = "[YOURSITE] "
      @sent_on     = Time.now
      @body[:<%= file_name %>] = <%= file_name %>
    end
end
