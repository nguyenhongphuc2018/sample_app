class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
    :following, :followers]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  before_action :find_user, except: [:index, :new, :create]

  def index
    @users = User.order(id: :asc).paginate page: params[:page]
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

  def show
    @user = User.find_by id: params[:id] || not_found
    @microposts = @user.microposts.paginate page: params[:page]
  end

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

  def following
    @title = t "following"
    find_user
    @users = @user.following.paginate page: params[:page]
    render :show_follow
  end

  def followers
    @title = t "followers"
    find_user
    @users = @user.followers.paginate page: params[:page]
    render :show_follow
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

  def correct_user
    find_user
    redirect_to root_url unless @user == current_user
  end

  def find_user
    @user = User.find_by id: params[:id]
    not_found unless @user
  end
end
