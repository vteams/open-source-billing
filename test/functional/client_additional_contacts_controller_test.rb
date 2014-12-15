require 'test_helper'

class ClientAdditionalContactsControllerTest < ActionController::TestCase
  setup do
    @client_additional_contact = client_additional_contacts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:client_additional_contacts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create client_additional_contact" do
    assert_difference('ClientAdditionalContact.count') do
      post :create, client_additional_contact: { client_id: @client_additional_contact.client_id, email: @client_additional_contact.email, first_name: @client_additional_contact.first_name, last_name: @client_additional_contact.last_name, password: @client_additional_contact.password, phone_1: @client_additional_contact.phone_1, phone_2: @client_additional_contact.phone_2, user_name: @client_additional_contact.user_name }
    end

    assert_redirected_to client_additional_contact_path(assigns(:client_additional_contact))
  end

  test "should show client_additional_contact" do
    get :show, id: @client_additional_contact
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @client_additional_contact
    assert_response :success
  end

  test "should update client_additional_contact" do
    put :update, id: @client_additional_contact, client_additional_contact: { client_id: @client_additional_contact.client_id, email: @client_additional_contact.email, first_name: @client_additional_contact.first_name, last_name: @client_additional_contact.last_name, password: @client_additional_contact.password, phone_1: @client_additional_contact.phone_1, phone_2: @client_additional_contact.phone_2, user_name: @client_additional_contact.user_name }
    assert_redirected_to client_additional_contact_path(assigns(:client_additional_contact))
  end

  test "should destroy client_additional_contact" do
    assert_difference('ClientAdditionalContact.count', -1) do
      delete :destroy, id: @client_additional_contact
    end

    assert_redirected_to client_additional_contacts_path
  end
end
