class Notifier < ActionMailer::Base
  default :from => "system@example.com"

  # Simple Welcome mailer
  # => CUSTOMIZE FOR YOUR OWN APP
  #
  # @param [user] user that signed up
  # => user must respond to email_address_with_name and name
  def signup_notification(recipient)
    @account = recipient

    #attachments['an-image.jp'] = File.read("an-image.jpg")
    #attachments['terms.pdf'] = {:content => generate_your_pdf_here() }

    activation_url =  activate_url(:a => @account.access_token)

    mail(:to => recipient.email_address_with_name,
         :subject => "New account information") do |format|
      format.text { render :text => "Welcome!  #{recipient.name} go to #{activation_url}" }
      format.html { render :text => "<h1>Welcome</h1> #{recipient.name} <a href='#{activation_url}'>Click to Activate</a> " }
    end

  end

  def password_reset_instructions(user)
    @user = user
    @url  = edit_customer_password_reset_url(:id => user.perishable_token)
    mail(:to => user.email,
         :subject => "Reset Password Instructions")
  end
end
