require 'rails_helper'

RSpec.describe "tasks/edit", :type => :view do
  before(:each) do
    @task = assign(:task, Task.create!(
      :name => "MyString",
      :description => "MyString",
      :billable => false,
      :rate => "9.99"
    ))
  end

  it "renders the edit task form" do
    render

    assert_select "form[action=?][method=?]", task_path(@task), "post" do

      assert_select "input#task_name[name=?]", "task[name]"

      assert_select "input#task_description[name=?]", "task[description]"

      assert_select "input#task_billable[name=?]", "task[billable]"

      assert_select "input#task_rate[name=?]", "task[rate]"
    end
  end
end
