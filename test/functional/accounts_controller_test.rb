require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  setup do
    @account = companies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:accounts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create company" do
    assert_difference('Company.count') do

      post :create, account:   @account
    end

    assert_redirected_to company_path(assigns(:account))
  end

  test "should show company" do
    get :show, id: @account
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @account
    assert_response :success
  end

  test "should update company" do

    put :update, id: @account, account:   @account
    assert_redirected_to company_path(assigns(:account))
  end

  test "should destroy company" do
    assert_difference('Company.count', -1) do
      delete :destroy, id: @account
    end

    assert_redirected_to companies_path
  end
end
