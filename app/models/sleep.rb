class Sleep < ApplicationRecord
  belongs_to :user
  validates :clock_in, presence: true
  validates :clock_out, presence: true, if: -> { clock_out.present? }
  validate :clock_out_after_clock_in, if: -> { clock_out.present? }
  validates :duration, numericality: { greater_than: 0 }, allow_nil: true

  before_save :calculate_duration
  after_save :invalidate_cache
  after_destroy :invalidate_cache

  private

  def calculate_duration
    return unless clock_in && clock_out
    self.duration = duration_in_minutes
  end

  def duration_in_minutes
    ((clock_out - clock_in) / 60).to_i
  end

  def clock_out_after_clock_in
    errors.add(:clock_out, 'must be after clock_in') if clock_out <= clock_in
  end

  def invalidate_cache
    # When a sleep record changes, the "friends' sleep" feed of anyone following this user is now stale.
    # We need to invalidate the cache for each follower.
    user.followers.find_each do |follower|
      # This matches the cache key structure in FriendsSleepsQuery
      Rails.cache.delete_matched("friends_sleeps/v2/#{follower.id}-*")
    end
  end
end
