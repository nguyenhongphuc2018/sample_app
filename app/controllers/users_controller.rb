class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.where(activated: FILL_IN).paginate(page: params[:page])
  end

  def destroy
    User.find_by(id: params[:id]).destroy
    flash[:success] = t "user_deleted"
    redirect_to users_url
  end

  def new
    @user = User.new
  end

  def show
    redirect_to root_url and return unless FILL_IN
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render :new
    end
  end

  def edit
    @user = User.find_by id: params[:id]
  end

  def update
    @user = User.find_by id: params[:id]
    if @user.update_attributes user_params
      flash[:success] = t "profile_update"
      redirect_to @user
    else
      render "edit"
    end
  end

  # Confirms a logged-in user.
  def logged_in_user
    return if logged_in?
      flash[:danger] = t "pls_login"
      redirect_to login_url
  end

  # Confirms the correct user.
  def correct_user
    @user = User.find_by id: params[:id]
    redirect_to(root_url) unless @user == current_user
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  private
  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  # Confirms an admin user.
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
