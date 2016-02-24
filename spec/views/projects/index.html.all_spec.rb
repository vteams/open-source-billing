require 'rails_helper'

RSpec.describe "projects/index", :type => :view do
  before(:each) do
    assign(:projects, [
      Project.create!(),
      Project.create!()
    ])
  end

  it "renders a list of projects" do
    render
  end
end
