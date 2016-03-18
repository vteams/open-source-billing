require "rails_helper"

RSpec.describe ExpensesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/expenses").to route_to("expenses#index")
    end

    it "routes to #new" do
      expect(:get => "/expenses/new").to route_to("expenses#new")
    end

    it "routes to #show" do
      expect(:get => "/expenses/1").to route_to("expenses#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/expenses/1/edit").to route_to("expenses#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/expenses").to route_to("expenses#create")
    end

    it "routes to #update" do
      expect(:put => "/expenses/1").to route_to("expenses#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/expenses/1").to route_to("expenses#destroy", :id => "1")
    end

  end
end
