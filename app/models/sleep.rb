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
    # Invalidate cache for user summaries on sleep record changes
    Rails.cache.delete_matched("user_summary_#{user_id}_*")
  end
end
