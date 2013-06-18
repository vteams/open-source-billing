require 'test_helper'

class EmailTemplatesControllerTest < ActionController::TestCase
  setup do
    @email_template = email_templates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:email_templates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create email_template" do
    assert_difference('EmailTemplate.count') do
      post :create, email_template: { body: @email_template.body, email_from: @email_template.email_from, subject: @email_template.subject, template_type: @email_template.template_type }
    end

    assert_redirected_to email_template_path(assigns(:email_template))
  end

  test "should show email_template" do
    get :show, id: @email_template
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @email_template
    assert_response :success
  end

  test "should update email_template" do
    put :update, id: @email_template, email_template: { body: @email_template.body, email_from: @email_template.email_from, subject: @email_template.subject, template_type: @email_template.template_type }
    assert_redirected_to email_template_path(assigns(:email_template))
  end

  test "should destroy email_template" do
    assert_difference('EmailTemplate.count', -1) do
      delete :destroy, id: @email_template
    end

    assert_redirected_to email_templates_path
  end
end
