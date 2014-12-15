require 'test_helper'

class CompaniesControllerTest < ActionController::TestCase
  setup do
    @company = companies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:companies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create company" do
    assert_difference('Company.count') do
      post :create, company: { account_id: @company.account_id, city: @company.city, company_name: @company.company_name, company_tag_line: @company.company_tag_line, contact_name: @company.contact_name, contact_title: @company.contact_title, country: @company.country, email: @company.email, fax_number: @company.fax_number, logo: @company.logo, memo: @company.memo, phone_number: @company.phone_number, postal_or_zipcode: @company.postal_or_zipcode, province_or_state: @company.province_or_state, street_address_1: @company.street_address_1, street_address_2: @company.street_address_2 }
    end

    assert_redirected_to company_path(assigns(:company))
  end

  test "should show company" do
    get :show, id: @company
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @company
    assert_response :success
  end

  test "should update company" do
    put :update, id: @company, company: { account_id: @company.account_id, city: @company.city, company_name: @company.company_name, company_tag_line: @company.company_tag_line, contact_name: @company.contact_name, contact_title: @company.contact_title, country: @company.country, email: @company.email, fax_number: @company.fax_number, logo: @company.logo, memo: @company.memo, phone_number: @company.phone_number, postal_or_zipcode: @company.postal_or_zipcode, province_or_state: @company.province_or_state, street_address_1: @company.street_address_1, street_address_2: @company.street_address_2 }
    assert_redirected_to company_path(assigns(:company))
  end

  test "should destroy company" do
    assert_difference('Company.count', -1) do
      delete :destroy, id: @company
    end

    assert_redirected_to companies_path
  end
end
