require 'rails_helper'

RSpec.describe "projects/new", :type => :view do
  before(:each) do
    assign(:project, Project.new())
  end

  it "renders new project form" do
    render

    assert_select "form[action=?][method=?]", projects_path, "post" do
    end
  end
end
