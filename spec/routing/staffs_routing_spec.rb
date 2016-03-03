require "rails_helper"

RSpec.describe StaffsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/staffs").to route_to("staffs#index")
    end

    it "routes to #new" do
      expect(:get => "/staffs/new").to route_to("staffs#new")
    end

    it "routes to #show" do
      expect(:get => "/staffs/1").to route_to("staffs#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/staffs/1/edit").to route_to("staffs#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/staffs").to route_to("staffs#create")
    end

    it "routes to #update" do
      expect(:put => "/staffs/1").to route_to("staffs#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/staffs/1").to route_to("staffs#destroy", :id => "1")
    end

  end
end
