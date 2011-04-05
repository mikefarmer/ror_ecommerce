class Customer::RegistrationsController < ApplicationController
  def new
    @user         = User.new
    @user_session = UserSession.new
  end

  def create
    @user = User.new(params[:user])
    @user.format_birth_date(params[:user][:birth_date]) if params[:user][:birth_date].present?
    # Saving without session maintenance to skip
    # auto-login which can't happen here because
    # the User has not yet been activated
    if @user.save_without_session_maintenance
      @user.deliver_activation_instructions!
      UserSession.new(@user.attributes)
      flash[:notice] = "Your account has been created. Please check your e-mail for your account activation instructions!"
      redirect_to root_url
    else
      flash[:error] = "There was a problem logging you in. Try again."
      @user_session = UserSession.new
      render :action => :new
    end
  end

  def edit
  end


  def activate

    @user = User.find_by_access_token params[:a]
    if @user && @user.activate
      @user_session = UserSession.create(@user, true) 
      # This is copied from the UserSessions#create action. There is probably a more DRY way to do this.
      cookies[:hadean_uid] = @user_session.record.access_token
      session[:authenticated_at] = Time.now
      
      ## if there is a cart make sure the user_id is correct
      #set_user_to_cart_items
      
      flash[:notice] = "Welcome back #{@user.name}"
    else
      flash[:notice] = "Invalid Activation URL!"
    end
    redirect_to root_url
    
  end

end
