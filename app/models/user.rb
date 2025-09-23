class User < ApplicationRecord
  has_many :sleeps
  has_many :follows_as_follower, class_name: "Follow", foreign_key: "follower_id"
  has_many :follows_as_followed, class_name: "Follow", foreign_key: "followed_id"
  has_many :following, through: :follows_as_follower, source: :followed
  has_many :followers, through: :follows_as_followed, source: :follower

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :by_name, ->(name) { where("lower(name) = ?", name.downcase) }

  # Finds the user with the most followers.
  def self.with_most_followers
    joins(:followers)
      .group("users.id")
      .order("COUNT(follows.id) DESC")
      .first
  end

  # Finds the user who is following the most other users.
  def self.following_the_most
    joins(:following)
      .group("users.id")
      .order("COUNT(follows.id) DESC")
      .first
  end
end
