class Api::V1::FollowsController < ApplicationController
  before_action :set_follow, only: [:destroy]

  def index
    follows = current_user.follows_as_follower.includes(:followed)
    render json: follows, status: :ok
  end

  def create
    followed = User.find(params[:followed_id])
    follow = current_user.follows_as_follower.build(followed: followed)
    if follow.save
      render json: follow, status: :created
    else
      render json: { errors: follow.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if @follow
      if @follow.destroy
        render json: { message: 'Unfollowed successfully' }, status: :ok
      else
        render json: { error: 'Unable to unfollow' }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Follow not found' }, status: :not_found
    end
  end

  private

  def set_follow
    @follow = current_user.follows_as_follower.find_by(followed_id: params[:id])
  end

  def current_user
    @current_user ||= User.find_by(id: params[:user_id])
  end
end
