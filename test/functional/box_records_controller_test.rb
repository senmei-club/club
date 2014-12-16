require 'test_helper'

class BoxRecordsControllerTest < ActionController::TestCase
  setup do
    @box_record = box_records(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:box_records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create box_record" do
    assert_difference('BoxRecord.count') do
      post :create, box_record: { box_id: @box_record.box_id, end_time: @box_record.end_time, manager_id: @box_record.manager_id, start_time: @box_record.start_time }
    end

    assert_redirected_to box_record_path(assigns(:box_record))
  end

  test "should show box_record" do
    get :show, id: @box_record
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @box_record
    assert_response :success
  end

  test "should update box_record" do
    put :update, id: @box_record, box_record: { box_id: @box_record.box_id, end_time: @box_record.end_time, manager_id: @box_record.manager_id, start_time: @box_record.start_time }
    assert_redirected_to box_record_path(assigns(:box_record))
  end

  test "should destroy box_record" do
    assert_difference('BoxRecord.count', -1) do
      delete :destroy, id: @box_record
    end

    assert_redirected_to box_records_path
  end
end
