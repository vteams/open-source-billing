require 'rails_helper'

RSpec.describe "tasks/new", :type => :view do
  before(:each) do
    assign(:task, Task.new(
      :name => "MyString",
      :description => "MyString",
      :billable => false,
      :rate => "9.99"
    ))
  end

  it "renders new task form" do
    render

    assert_select "form[action=?][method=?]", tasks_path, "post" do

      assert_select "input#task_name[name=?]", "task[name]"

      assert_select "input#task_description[name=?]", "task[description]"

      assert_select "input#task_billable[name=?]", "task[billable]"

      assert_select "input#task_rate[name=?]", "task[rate]"
    end
  end
end
