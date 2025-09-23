require "test_helper"

class Api::V1::FollowsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @start_date = 1.week.ago.to_date
    @end_date = Date.today
  end

  test "should get index" do
    get api_v1_follows_url, params: { user_id: @user.id }
    assert_response :success
  end

  test "should create follow" do
    assert_difference("@user.following.count") do
      post api_v1_follows_url, params: { followed_id: @other_user.id, user_id: @user.id }
    end
    assert_response :created
  end

  test "should not create duplicate follow" do
    @user.following << @other_user
    post api_v1_follows_url, params: { followed_id: @other_user.id, user_id: @user.id }
    assert_response :unprocessable_entity
  end

  test "should destroy follow" do
    follow = @user.follows_as_follower.create(followed: @other_user)
    assert_difference("@user.following.count", -1) do
      delete api_v1_follow_url(follow.followed_id), params: { user_id: @user.id }
    end
    assert_response :success
  end

  test "should not destroy non-existent follow" do
    delete api_v1_follow_url(@other_user.id), params: { user_id: @user.id }
    assert_response :not_found
  end
end
