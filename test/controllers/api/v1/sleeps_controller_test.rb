require "test_helper"

class Api::V1::SleepsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user = users(:one)
    @other_user = users(:two)
    @start_date = 1.week.ago.to_date
    @end_date = Date.today

    @sleep = sleeps(:one)
  end

  test "should get index" do
    get api_v1_sleeps_url, params: { user_id: @user.id }
    assert_response :success
    sleeps = JSON.parse(response.body)
    assert_equal @user.sleeps.count, sleeps.size
  end

  test "should create sleep" do
    assert_difference("@user.sleeps.count") do
      post api_v1_sleeps_url, params: { sleep: { clock_in: Time.now }, user_id: @user.id }
    end
    assert_response :created
  end

  test "should update sleep" do
    patch api_v1_sleep_url(@sleep), params: { sleep: { clock_out: Time.now }, user_id: @user.id }
    assert_response :success
    @sleep.reload
    assert @sleep.clock_out.present?
  end

  test "should get friends_sleeps with pagination and summaries" do
    # Override cache store for this test to enable caching
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new

    # Create follow relationship
    @user.following << @other_user

    # Destroy existing sleeps for @other_user to avoid fixture interference
    @other_user.sleeps.destroy_all

    # Create sleep records for the followed user, ordered by duration DESC
    sleep1 = @other_user.sleeps.create!(clock_in: @start_date + 1.day, clock_out: @start_date + 1.day + 8.hours, duration: 480)
    sleep2 = @other_user.sleeps.create!(clock_in: @start_date + 2.days, clock_out: @start_date + 2.days + 7.hours, duration: 420)

    # 1. First request: Cache miss, should enqueue a job and return a loading state.
    get friends_sleeps_api_v1_sleeps_url, params: { user_id: @user.id, start_date: @start_date.to_s, end_date: @end_date.to_s, page: 1, per_page: 1 }

    assert_response :success
    response_body = JSON.parse(response.body)
    assert_equal "loading", response_body["status"]
    assert_empty response_body["sleeps"]

    # 2. Perform the job that was enqueued by the first request to warm the cache
    # We also assert that exactly one job was enqueued.
    assert_enqueued_jobs 1
    perform_enqueued_jobs

    # 3. Second request: Cache hit, should return the actual data.
    get friends_sleeps_api_v1_sleeps_url, params: { user_id: @user.id, start_date: @start_date.to_s, end_date: @end_date.to_s, page: 1, per_page: 1 }
    assert_response :success
    response_body = JSON.parse(response.body)

    assert response_body["sleeps"].present?
    assert_equal 1, response_body["sleeps"].size
    assert_equal sleep1.id, response_body["sleeps"].first["id"] # Verify correct record is returned based on sorting
    assert response_body["summaries"].present?
    assert_equal 2, response_body["pagination"]["total_count"]
  ensure
    Rails.cache = original_cache
  end

  test "should return empty response for friends_sleeps if user follows no one" do
    # Ensure the user is not following anyone
    @user.following.destroy_all

    get friends_sleeps_api_v1_sleeps_url, params: { user_id: @user.id }
    assert_response :success

    response_body = JSON.parse(response.body)
    assert_empty response_body["sleeps"]
    assert_not response_body.key?("status"), "Should not return 'loading' status"
  end
end
