require 'rails_helper'

RSpec.describe "expenses/show", :type => :view do
  before(:each) do
    @expense = assign(:expense, Expense.create!(
      :amount => 1.5,
      :category => "Category",
      :note => "MyText",
      :client_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1.5/)
    expect(rendered).to match(/Category/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/1/)
  end
end
