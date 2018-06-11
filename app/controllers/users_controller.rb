class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  before_action :find_user, except: [:index, :new, :create]

  def index
    @users = User.order(id: :desc).paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "pls_check_email"
      redirect_to root_url
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @user.update_attributes user_params
      flash[:success] = t "profile_update"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @use && !current_user?(@user) && @user.destroy
      flash[:success] = t "user_deleted"
    else
      flash[:warring] = t "permission"
    end
    redirect_to users_url
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

  # Confirms a logged-in user.
  def logged_in_user
    return if logged_in?
    flash[:danger] = t "pls_login"
    redirect_to login_url
  end

  # Confirms the correct user.
  def correct_user
    find_user
    redirect_to root_url unless @user == current_user
  end

  # Return the user
  def find_user
    @user = User.find_by id: params[:id]
    not_found unless @user
  end
end
