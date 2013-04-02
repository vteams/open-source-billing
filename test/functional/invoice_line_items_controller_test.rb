require 'test_helper'

class InvoiceLineItemsControllerTest < ActionController::TestCase
  setup do
    @invoice_line_item = invoice_line_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:invoice_line_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create invoice_line_item" do
    assert_difference('InvoiceLineItem.count') do
      post :create, invoice_line_item: { invoice_id: @invoice_line_item.invoice_id, item_description: @invoice_line_item.item_description, item_id: @invoice_line_item.item_id, item_name: @invoice_line_item.item_name, item_quantity: @invoice_line_item.item_quantity, item_unit_cost: @invoice_line_item.item_unit_cost, tax_1: @invoice_line_item.tax_1, tax_2: @invoice_line_item.tax_2 }
    end

    assert_redirected_to invoice_line_item_path(assigns(:invoice_line_item))
  end

  test "should show invoice_line_item" do
    get :show, id: @invoice_line_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @invoice_line_item
    assert_response :success
  end

  test "should update invoice_line_item" do
    put :update, id: @invoice_line_item, invoice_line_item: { invoice_id: @invoice_line_item.invoice_id, item_description: @invoice_line_item.item_description, item_id: @invoice_line_item.item_id, item_name: @invoice_line_item.item_name, item_quantity: @invoice_line_item.item_quantity, item_unit_cost: @invoice_line_item.item_unit_cost, tax_1: @invoice_line_item.tax_1, tax_2: @invoice_line_item.tax_2 }
    assert_redirected_to invoice_line_item_path(assigns(:invoice_line_item))
  end

  test "should destroy invoice_line_item" do
    assert_difference('InvoiceLineItem.count', -1) do
      delete :destroy, id: @invoice_line_item
    end

    assert_redirected_to invoice_line_items_path
  end
end
