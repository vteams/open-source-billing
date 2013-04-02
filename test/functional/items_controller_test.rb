require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
  setup do
    @item = items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create item" do
    assert_difference('Item.count') do
      post :create, item: { inventory: @item.inventory, item_description: @item.item_description, item_name: @item.item_name, quantity: @item.quantity, tax_1: @item.tax_1, tax_2: @item.tax_2, track_invetory: @item.track_invetory, unit_cost: @item.unit_cost }
    end

    assert_redirected_to item_path(assigns(:item))
  end

  test "should show item" do
    get :show, id: @item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @item
    assert_response :success
  end

  test "should update item" do
    put :update, id: @item, item: { inventory: @item.inventory, item_description: @item.item_description, item_name: @item.item_name, quantity: @item.quantity, tax_1: @item.tax_1, tax_2: @item.tax_2, track_invetory: @item.track_invetory, unit_cost: @item.unit_cost }
    assert_redirected_to item_path(assigns(:item))
  end

  test "should destroy item" do
    assert_difference('Item.count', -1) do
      delete :destroy, id: @item
    end

    assert_redirected_to items_path
  end
end
