require 'rails_helper'

RSpec.describe "projects/show", :type => :view do
  before(:each) do
    @project = assign(:project, Project.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
