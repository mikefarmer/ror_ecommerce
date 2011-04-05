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
      UserSession.create(@user, true) 
      flash[:notice] = "Welcome back #{@user.name}"
    else
      flash[:notice] = "Invalid Activation URL!"
    end
    redirect_to root_url
    
  end

end
