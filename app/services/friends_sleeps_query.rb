class FriendsSleepsQuery
  def initialize(user:, start_date: nil, end_date: nil, page: 1, per_page: 20)
    @user = user
    @start_date_str = start_date
    @end_date_str = end_date
    @page = page
    @per_page = per_page
  end

  def call
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      parse_dates
      return { errors: @errors } if @errors.present?

      followed_user_ids = @user.following.pluck(:id)
      return empty_response if followed_user_ids.empty?

      sleeps = fetch_paginated_sleeps(followed_user_ids)
      summaries = fetch_summaries(followed_user_ids)

      {
        sleeps: sleeps.as_json(include: :user),
        summaries: summaries,
        pagination: {
          current_page: sleeps.current_page,
          total_pages: sleeps.total_pages,
          total_count: sleeps.total_count
        }
      }
    end
  end

  private

  def parse_dates
    @errors = []
    @end_date = @end_date_str ? Date.parse(@end_date_str) : Date.today
    @start_date = @start_date_str ? Date.parse(@start_date_str) : @end_date - 1.week
  rescue ArgumentError
    @errors << "Invalid date format. Please use YYYY-MM-DD."
  end

  def fetch_paginated_sleeps(user_ids)
    Sleep.where(user_id: user_ids)
         .where(clock_in: @start_date.beginning_of_day..@end_date.end_of_day)
         .includes(:user)
         .order('duration DESC')
         .page(@page)
         .per(@per_page)
  end

  def fetch_summaries(user_ids)
    # This query is now part of the larger cached block, so direct caching here is no longer needed.
    Sleep.where(user_id: user_ids)
         .where(clock_in: @start_date.beginning_of_day..@end_date.end_of_day)
         .group(:user_id)
         .sum(:duration)
  end

  def empty_response
    {
      sleeps: [],
      summaries: {},
      pagination: {
        current_page: 1, total_pages: 0, total_count: 0
      }
    }
  end

  def cache_key
    # Cache version includes followed users' count and latest update time to bust cache on follow/unfollow.
    follow_version = @user.follows_as_follower.pluck(:updated_at).max.to_i
    "friends_sleeps/v2/#{@user.id}-#{follow_version}/#{@start_date_str}-#{@end_date_str}/p#{@page}-#{@per_page}"
  end
end
