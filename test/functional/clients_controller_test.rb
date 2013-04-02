require 'test_helper'

class ClientsControllerTest < ActionController::TestCase
  setup do
    @client = clients(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:clients)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create client" do
    assert_difference('Client.count') do
      post :create, client: { address_street1: @client.address_street1, address_street2: @client.address_street2, business_phone: @client.business_phone, city: @client.city, company_size: @client.company_size, country: @client.country, fax: @client.fax, industry: @client.industry, internal_notes: @client.internal_notes, organization_name: @client.organization_name, postal_zip_code: @client.postal_zip_code, province_state: @client.province_state, send_invoice_by: @client.send_invoice_by }
    end

    assert_redirected_to client_path(assigns(:client))
  end

  test "should show client" do
    get :show, id: @client
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @client
    assert_response :success
  end

  test "should update client" do
    put :update, id: @client, client: { address_street1: @client.address_street1, address_street2: @client.address_street2, business_phone: @client.business_phone, city: @client.city, company_size: @client.company_size, country: @client.country, fax: @client.fax, industry: @client.industry, internal_notes: @client.internal_notes, organization_name: @client.organization_name, postal_zip_code: @client.postal_zip_code, province_state: @client.province_state, send_invoice_by: @client.send_invoice_by }
    assert_redirected_to client_path(assigns(:client))
  end

  test "should destroy client" do
    assert_difference('Client.count', -1) do
      delete :destroy, id: @client
    end

    assert_redirected_to clients_path
  end
end
