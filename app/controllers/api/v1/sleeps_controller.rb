class Api::V1::SleepsController < ApplicationController
  before_action :set_sleep, only: [:update]

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
    # Set default date range to the last week if not provided
    end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : end_date - 1.week

    # Get followed users' IDs
    followed_user_ids = current_user.following.pluck(:id)

    # Query sleep records with date range limitation for performance
    sleeps = Sleep.where(user_id: followed_user_ids)
                  .where(clock_in: start_date.beginning_of_day..end_date.end_of_day)
                  .includes(:user)
                  .order(clock_in: :desc)

    # Apply pagination using Kaminari
    paginated_sleeps = sleeps.page(params[:page]).per(params[:per_page] || 20)

    # Cache user summaries (e.g., total sleep for each friend in the date range)
    summaries = followed_user_ids.map do |user_id|
      Rails.cache.fetch("user_summary_#{user_id}_#{start_date}_#{end_date}", expires_in: 1.hour) do
        Sleep.where(user_id: user_id, clock_in: start_date.beginning_of_day..end_date.end_of_day)
             .sum(:duration)
      end
    end

    render json: {
      sleeps: paginated_sleeps.as_json(include: :user),
      summaries: summaries,
      pagination: {
        current_page: paginated_sleeps.current_page,
        total_pages: paginated_sleeps.total_pages,
        total_count: paginated_sleeps.total_count
      }
    }, status: :ok
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
end
