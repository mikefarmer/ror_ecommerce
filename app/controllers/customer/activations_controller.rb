class Customer::ActivationsController < ApplicationController

  # This method should be an "update method" but
  # I imagine some email clients will have a hard time with this.
  # plus some people will want to copy and paste the link.
  def show
    @user = User.find_by_perishable_token(params[:a])
    if @user && @user.activate!
      @user_session = UserSession.create(@user, true) 
      # This is copied from the UserSessions#create action. There is probably a more DRY way to do this.
      cookies[:hadean_uid] = @user_session.record.access_token
      session[:authenticated_at] = Time.now

      flash[:notice] = "Welcome back #{@user.name}"
    else
      flash[:notice] = "Invalid Activation URL!"
    end
    redirect_to root_url
  end

  private

  def form_info

  end
end
