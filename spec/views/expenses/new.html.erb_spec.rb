require 'rails_helper'

RSpec.describe "expenses/new", :type => :view do
  before(:each) do
    assign(:expense, Expense.new(
      :amount => 1.5,
      :category => "MyString",
      :note => "MyText",
      :client_id => 1
    ))
  end

  it "renders new expense form" do
    render

    assert_select "form[action=?][method=?]", expenses_path, "post" do

      assert_select "input#expense_amount[name=?]", "expense[amount]"

      assert_select "input#expense_category[name=?]", "expense[category]"

      assert_select "textarea#expense_note[name=?]", "expense[note]"

      assert_select "input#expense_client_id[name=?]", "expense[client_id]"
    end
  end
end
