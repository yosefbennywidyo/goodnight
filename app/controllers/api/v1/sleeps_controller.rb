class Api::V1::SleepsController < ApplicationController
  before_action :set_sleep, only: [:update]
  before_action :require_user

  def index
    sleeps = current_user.sleeps.order(created_at: :asc)
    render json: sleeps, status: :ok
  end

  def create
    sleep_record = current_user.sleeps.build(sleep_params)
    if sleep_record.save
      render json: sleep_record, status: :created
    else
      render json: { errors: sleep_record.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @sleep.update(sleep_params)
      render json: @sleep, status: :ok
    else
      render json: { errors: @sleep.errors }, status: :unprocessable_entity
    end
  end

  def friends_sleeps
    result = FriendsSleepsQuery.new(
      user: current_user,
      start_date: params[:start_date],
      end_date: params[:end_date],
      page: params[:page],
      per_page: params[:per_page]
    ).call

    if result[:errors]
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    else
      render json: result, status: :ok
    end
  end

  private

  def set_sleep
    @sleep = current_user.sleeps.find(params[:id])
  end

  def sleep_params
    params.require(:sleep).permit(:clock_in, :clock_out)
  end

  def current_user
    @current_user ||= User.find_by(id: params[:user_id])
  end

  def require_user
    return if current_user
    render json: { error: 'User not found' }, status: :not_found
  end
end
