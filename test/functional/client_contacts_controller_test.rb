require 'test_helper'

class ClientContactsControllerTest < ActionController::TestCase
  setup do
    @client_contact = client_contacts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:client_contacts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create client_contact" do
    assert_difference('ClientContact.count') do
      post :create, client_contact: { client_id: @client_contact.client_id, email: @client_contact.email, first_name: @client_contact.first_name, last_name: @client_contact.last_name, phone1: @client_contact.phone1, phone2: @client_contact.phone2 }
    end

    assert_redirected_to client_contact_path(assigns(:client_contact))
  end

  test "should show client_contact" do
    get :show, id: @client_contact
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @client_contact
    assert_response :success
  end

  test "should update client_contact" do
    put :update, id: @client_contact, client_contact: { client_id: @client_contact.client_id, email: @client_contact.email, first_name: @client_contact.first_name, last_name: @client_contact.last_name, phone1: @client_contact.phone1, phone2: @client_contact.phone2 }
    assert_redirected_to client_contact_path(assigns(:client_contact))
  end

  test "should destroy client_contact" do
    assert_difference('ClientContact.count', -1) do
      delete :destroy, id: @client_contact
    end

    assert_redirected_to client_contacts_path
  end
end
