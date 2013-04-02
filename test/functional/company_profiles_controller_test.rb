require 'test_helper'

class CompanyProfilesControllerTest < ActionController::TestCase
  setup do
    @company_profile = company_profiles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:company_profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create company_profile" do
    assert_difference('CompanyProfile.count') do
      post :create, company_profile: { admin_billing_rate_per_hour: @company_profile.admin_billing_rate_per_hour, admin_email: @company_profile.admin_email, admin_first_name: @company_profile.admin_first_name, admin_last_name: @company_profile.admin_last_name, admin_password: @company_profile.admin_password, admin_user_name: @company_profile.admin_user_name, auto_dst_adjustment: @company_profile.auto_dst_adjustment, city: @company_profile.city, country: @company_profile.country, currecy_symbol: @company_profile.currecy_symbol, currency_code: @company_profile.currency_code, email: @company_profile.email, fax: @company_profile.fax, org_name: @company_profile.org_name, phone_business: @company_profile.phone_business, phone_mobile: @company_profile.phone_mobile, postal_or_zip_code: @company_profile.postal_or_zip_code, profession: @company_profile.profession, province_or_state: @company_profile.province_or_state, street_address_1: @company_profile.street_address_1, street_address_2: @company_profile.street_address_2, time_zone: @company_profile.time_zone }
    end

    assert_redirected_to company_profile_path(assigns(:company_profile))
  end

  test "should show company_profile" do
    get :show, id: @company_profile
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @company_profile
    assert_response :success
  end

  test "should update company_profile" do
    put :update, id: @company_profile, company_profile: { admin_billing_rate_per_hour: @company_profile.admin_billing_rate_per_hour, admin_email: @company_profile.admin_email, admin_first_name: @company_profile.admin_first_name, admin_last_name: @company_profile.admin_last_name, admin_password: @company_profile.admin_password, admin_user_name: @company_profile.admin_user_name, auto_dst_adjustment: @company_profile.auto_dst_adjustment, city: @company_profile.city, country: @company_profile.country, currecy_symbol: @company_profile.currecy_symbol, currency_code: @company_profile.currency_code, email: @company_profile.email, fax: @company_profile.fax, org_name: @company_profile.org_name, phone_business: @company_profile.phone_business, phone_mobile: @company_profile.phone_mobile, postal_or_zip_code: @company_profile.postal_or_zip_code, profession: @company_profile.profession, province_or_state: @company_profile.province_or_state, street_address_1: @company_profile.street_address_1, street_address_2: @company_profile.street_address_2, time_zone: @company_profile.time_zone }
    assert_redirected_to company_profile_path(assigns(:company_profile))
  end

  test "should destroy company_profile" do
    assert_difference('CompanyProfile.count', -1) do
      delete :destroy, id: @company_profile
    end

    assert_redirected_to company_profiles_path
  end
end
