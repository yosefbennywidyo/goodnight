require 'test_helper'

class Api::V1::SleepsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @start_date = 1.week.ago.to_date
    @end_date = Date.today

    @sleep = sleeps(:one)
  end

  test 'should get index' do
    get api_v1_sleeps_url, params: { user_id: @user.id }
    assert_response :success
    sleeps = JSON.parse(response.body)
    assert_equal @user.sleeps.count, sleeps.size
  end

  test 'should create sleep' do
    assert_difference('@user.sleeps.count') do
      post api_v1_sleeps_url, params: { sleep: { clock_in: Time.now }, user_id: @user.id }
    end
    assert_response :created
  end

  test 'should update sleep' do
    patch api_v1_sleep_url(@sleep), params: { sleep: { clock_out: Time.now }, user_id: @user.id }
    assert_response :success
    @sleep.reload
    assert @sleep.clock_out.present?
  end

  test 'should get friends_sleeps with pagination and summaries' do
    # Create follow relationship
    @user.following << @other_user

    # Destroy existing sleeps for @other_user to avoid fixture interference
    @other_user.sleeps.destroy_all

    # Create sleep records for the followed user
    sleep1 = @other_user.sleeps.create!(clock_in: @start_date + 1.day, clock_out: @start_date + 1.day + 8.hours, duration: 480)
    sleep2 = @other_user.sleeps.create!(clock_in: @start_date + 2.days, clock_out: @start_date + 2.days + 7.hours, duration: 420)

    # Make request with pagination
    get friends_sleeps_api_v1_sleeps_url, params: { user_id: @user.id, start_date: @start_date, end_date: @end_date, page: 1, per_page: 1 }

    assert_response :success

    response_body = JSON.parse(response.body)
    assert response_body['sleeps'].present?
    assert_equal 1, response_body['sleeps'].size  # Per page limit
    assert response_body['summaries'].present?
    assert response_body['pagination'].present?
    assert_equal 1, response_body['pagination']['current_page']
    assert_equal 2, response_body['pagination']['total_count']
  end
end
