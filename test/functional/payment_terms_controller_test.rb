require 'test_helper'

class PaymentTermsControllerTest < ActionController::TestCase
  setup do
    @payment_term = payment_terms(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:payment_terms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create payment_term" do
    assert_difference('PaymentTerm.count') do
      post :create, payment_term: { description: @payment_term.description, number_of_days: @payment_term.number_of_days }
    end

    assert_redirected_to payment_term_path(assigns(:payment_term))
  end

  test "should show payment_term" do
    get :show, id: @payment_term
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @payment_term
    assert_response :success
  end

  test "should update payment_term" do
    put :update, id: @payment_term, payment_term: { description: @payment_term.description, number_of_days: @payment_term.number_of_days }
    assert_redirected_to payment_term_path(assigns(:payment_term))
  end

  test "should destroy payment_term" do
    assert_difference('PaymentTerm.count', -1) do
      delete :destroy, id: @payment_term
    end

    assert_redirected_to payment_terms_path
  end
end
