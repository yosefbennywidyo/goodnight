require 'test_helper'

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
  end

  test 'should get index' do
    get api_v1_users_url
    assert_response :success
    assert_equal User.count, JSON.parse(response.body).size
  end

  test 'should show user' do
    get api_v1_user_url(@user)
    assert_response :success
    assert_equal @user.name, JSON.parse(response.body)['name']
  end

  test 'should create user' do
    assert_difference('User.count') do
      post api_v1_users_url, params: { user: { name: 'New User' } }
    end
    assert_response :created
  end

  test 'should not create user with invalid params' do
    post api_v1_users_url, params: { user: { name: '' } }
    assert_response :unprocessable_entity
  end

  test 'should follow user' do
    assert_difference('@user.following.count') do
      post follow_api_v1_user_url(@other_user), params: { user_id: @user.id }
    end
    assert_response :success
  end

  test 'should unfollow user' do
    @user.following << @other_user
    assert_difference('@user.following.count', -1) do
      delete unfollow_api_v1_user_url(@other_user), params: { user_id: @user.id }
    end
    assert_response :success
  end

  test 'should not unfollow if not following' do
    delete unfollow_api_v1_user_url(@other_user), params: { user_id: @user.id }
    assert_response :not_found
  end
end
