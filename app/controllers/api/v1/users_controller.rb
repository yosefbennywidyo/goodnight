class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: [:show, :follow, :unfollow]

  def index
    users = User.all
    render json: users, status: :ok
  end

  def show
    render json: @user, status: :ok
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors }, status: :unprocessable_entity
    end
  end

  def follow
    follow = current_user.follows_as_follower.build(followed: @user)
    if follow.save
      render json: { message: 'Followed successfully' }, status: :ok
    else
      render json: { errors: follow.errors }, status: :unprocessable_entity
    end
  end

  def unfollow
    follow = current_user.follows_as_follower.find_by(followed: @user)
    if follow&.destroy
      render json: { message: 'Unfollowed successfully' }, status: :ok
    else
      render json: { error: 'Not following' }, status: :not_found
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name)
  end

  def current_user
    # Assuming authentication is handled elsewhere, e.g., via JWT or session
    @current_user ||= User.find_by(id: params[:user_id]) # Placeholder; replace with actual auth
  end
end
