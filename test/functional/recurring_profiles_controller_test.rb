require 'test_helper'

class RecurringProfilesControllerTest < ActionController::TestCase
  setup do
    @recurring_profile = recurring_profiles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:recurring_profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create recurring_profile" do
    assert_difference('RecurringProfile.count') do
      post :create, recurring_profile: { client_id: @recurring_profile.client_id, discount_amount: @recurring_profile.discount_amount, discount_percentage: @recurring_profile.discount_percentage, first_invoice_date: @recurring_profile.first_invoice_date, frequency: @recurring_profile.frequency, gateway_id: @recurring_profile.gateway_id, notes: @recurring_profile.notes, occurrences: @recurring_profile.occurrences, po_number: @recurring_profile.po_number, prorate: @recurring_profile.prorate, prorate_for: @recurring_profile.prorate_for, status: @recurring_profile.status, sub_total: @recurring_profile.sub_total, tax_amount: @recurring_profile.tax_amount, tems: @recurring_profile.tems }
    end

    assert_redirected_to recurring_profile_path(assigns(:recurring_profile))
  end

  test "should show recurring_profile" do
    get :show, id: @recurring_profile
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @recurring_profile
    assert_response :success
  end

  test "should update recurring_profile" do
    put :update, id: @recurring_profile, recurring_profile: { client_id: @recurring_profile.client_id, discount_amount: @recurring_profile.discount_amount, discount_percentage: @recurring_profile.discount_percentage, first_invoice_date: @recurring_profile.first_invoice_date, frequency: @recurring_profile.frequency, gateway_id: @recurring_profile.gateway_id, notes: @recurring_profile.notes, occurrences: @recurring_profile.occurrences, po_number: @recurring_profile.po_number, prorate: @recurring_profile.prorate, prorate_for: @recurring_profile.prorate_for, status: @recurring_profile.status, sub_total: @recurring_profile.sub_total, tax_amount: @recurring_profile.tax_amount, tems: @recurring_profile.tems }
    assert_redirected_to recurring_profile_path(assigns(:recurring_profile))
  end

  test "should destroy recurring_profile" do
    assert_difference('RecurringProfile.count', -1) do
      delete :destroy, id: @recurring_profile
    end

    assert_redirected_to recurring_profiles_path
  end
end
