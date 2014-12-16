require 'test_helper'

class AuthLevelsControllerTest < ActionController::TestCase
  setup do
    @auth_level = auth_levels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:auth_levels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create auth_level" do
    assert_difference('AuthLevel.count') do
      post :create, auth_level: { action: @auth_level.action, allowed_path: @auth_level.allowed_path, id: @auth_level.id, level: @auth_level.level }
    end

    assert_redirected_to auth_level_path(assigns(:auth_level))
  end

  test "should show auth_level" do
    get :show, id: @auth_level
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @auth_level
    assert_response :success
  end

  test "should update auth_level" do
    put :update, id: @auth_level, auth_level: { action: @auth_level.action, allowed_path: @auth_level.allowed_path, id: @auth_level.id, level: @auth_level.level }
    assert_redirected_to auth_level_path(assigns(:auth_level))
  end

  test "should destroy auth_level" do
    assert_difference('AuthLevel.count', -1) do
      delete :destroy, id: @auth_level
    end

    assert_redirected_to auth_levels_path
  end
end
