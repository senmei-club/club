require 'test_helper'

class UserBoxRecordsControllerTest < ActionController::TestCase
  setup do
    @user_box_record = user_box_records(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_box_records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_box_record" do
    assert_difference('UserBoxRecord.count') do
      post :create, user_box_record: { box_id: @user_box_record.box_id, card_id: @user_box_record.card_id, data_string: @user_box_record.data_string, id: @user_box_record.id, machine_id: @user_box_record.machine_id, time: @user_box_record.time, type: @user_box_record.type, user_character: @user_box_record.user_character, user_id: @user_box_record.user_id }
    end

    assert_redirected_to user_box_record_path(assigns(:user_box_record))
  end

  test "should show user_box_record" do
    get :show, id: @user_box_record
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_box_record
    assert_response :success
  end

  test "should update user_box_record" do
    put :update, id: @user_box_record, user_box_record: { box_id: @user_box_record.box_id, card_id: @user_box_record.card_id, data_string: @user_box_record.data_string, id: @user_box_record.id, machine_id: @user_box_record.machine_id, time: @user_box_record.time, type: @user_box_record.type, user_character: @user_box_record.user_character, user_id: @user_box_record.user_id }
    assert_redirected_to user_box_record_path(assigns(:user_box_record))
  end

  test "should destroy user_box_record" do
    assert_difference('UserBoxRecord.count', -1) do
      delete :destroy, id: @user_box_record
    end

    assert_redirected_to user_box_records_path
  end
end
