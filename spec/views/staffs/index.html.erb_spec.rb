require 'rails_helper'

RSpec.describe "staffs/index", :type => :view do
  before(:each) do
    assign(:staffs, [
      Staff.create!(
        :email => "Email",
        :name => "Name",
        :rate => "9.99",
        :created_by => 1,
        :updated_by => 2
      ),
      Staff.create!(
        :email => "Email",
        :name => "Name",
        :rate => "9.99",
        :created_by => 1,
        :updated_by => 2
      )
    ])
  end

  it "renders a list of staffs" do
    render
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
