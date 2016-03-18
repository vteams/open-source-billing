require 'rails_helper'

RSpec.describe "Expenses", :type => :request do
  describe "GET /expenses" do
    it "works! (now write some real specs)" do
      get expenses_path
      expect(response).to have_http_status(200)
    end
  end
end
