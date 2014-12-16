require 'test_helper'

class SysConfigsControllerTest < ActionController::TestCase
  setup do
    @sys_config = sys_configs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sys_configs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sys_config" do
    assert_difference('SysConfig.count') do
      post :create, sys_config: { config_name: @sys_config.config_name, config_value: @sys_config.config_value, id: @sys_config.id }
    end

    assert_redirected_to sys_config_path(assigns(:sys_config))
  end

  test "should show sys_config" do
    get :show, id: @sys_config
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sys_config
    assert_response :success
  end

  test "should update sys_config" do
    put :update, id: @sys_config, sys_config: { config_name: @sys_config.config_name, config_value: @sys_config.config_value, id: @sys_config.id }
    assert_redirected_to sys_config_path(assigns(:sys_config))
  end

  test "should destroy sys_config" do
    assert_difference('SysConfig.count', -1) do
      delete :destroy, id: @sys_config
    end

    assert_redirected_to sys_configs_path
  end
end
