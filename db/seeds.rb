# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
1000.times do |i|
  User.create!(name: "User #{i + 1}")
  puts "Created User #{i + 1}" if (i + 1) % 100 == 0  # Progress indicator every 100 users
end

puts "Finished creating 1000 users."

users = User.all.to_a  # Load all users into memory for efficiency

users.each_with_index do |user, index|
  # Select 5 random users to follow, excluding self
  potential_follows = users.reject { |u| u.id == user.id }.sample(5)

  potential_follows.each do |followed|
    # Create follow if it doesn't exist
    user.follows_as_follower.find_or_create_by(followed: followed)
  end

  puts "Set up follows for User #{user.id}" if (index + 1) % 100 == 0  # Progress every 100 users
end

puts "Finished setting up follows for all users."

ers.each_with_index do |user, index|
  # Generate 5-10 sleep records per user
  num_sleeps = rand(5..10)

  num_sleeps.times do
    # Random clock_in time in the past 7 days, between 10 PM and 2 AM
    base_date = rand(7).days.ago.to_date
    clock_in_hour = [22, 23, 0, 1, 2].sample  # Valid hours: 22-23 (PM), 0-2 (AM)
    clock_in = Time.zone.parse("#{base_date} #{clock_in_hour}:00")

    # Random duration between 4 and 10 hours
    duration_hours = rand(4..10)
    clock_out = clock_in + duration_hours.hours

    # Create sleep record
    user.sleeps.create!(clock_in: clock_in, clock_out: clock_out, duration: duration_hours * 60)  # Duration in minutes
  end

  puts "Set up sleeps for User #{user.id}" if (index + 1) % 100 == 0  # Progress every 100 users
end

puts "Finished setting up sleep records for all users."
