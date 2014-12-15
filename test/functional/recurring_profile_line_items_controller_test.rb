require 'test_helper'

class RecurringProfileLineItemsControllerTest < ActionController::TestCase
  setup do
    @recurring_profile_line_item = recurring_profile_line_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:recurring_profile_line_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create recurring_profile_line_item" do
    assert_difference('RecurringProfileLineItem.count') do
      post :create, recurring_profile_line_item: {  }
    end

    assert_redirected_to recurring_profile_line_item_path(assigns(:recurring_profile_line_item))
  end

  test "should show recurring_profile_line_item" do
    get :show, id: @recurring_profile_line_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @recurring_profile_line_item
    assert_response :success
  end

  test "should update recurring_profile_line_item" do
    put :update, id: @recurring_profile_line_item, recurring_profile_line_item: {  }
    assert_redirected_to recurring_profile_line_item_path(assigns(:recurring_profile_line_item))
  end

  test "should destroy recurring_profile_line_item" do
    assert_difference('RecurringProfileLineItem.count', -1) do
      delete :destroy, id: @recurring_profile_line_item
    end

    assert_redirected_to recurring_profile_line_items_path
  end
end
