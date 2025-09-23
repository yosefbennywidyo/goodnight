class WarmFriendsSleepsCacheJob < ApplicationJob
  queue_as :default

  def perform(user_id, start_date_str, end_date_str, page, per_page)
    user = User.find_by(id: user_id)
    return unless user

    # Instantiate the query object but call a new method to perform the actual work
    # This avoids the logic that would re-enqueue the job.
    FriendsSleepsQuery.new(
      user: user,
      start_date: start_date_str,
      end_date: end_date_str,
      page: page,
      per_page: per_page
    ).warm_cache
  end
end
