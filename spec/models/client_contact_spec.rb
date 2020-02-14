require 'rails_helper'

describe ClientContact do
  let(:client) do
    FactoryGirl.create(:client)
  end

  let(:client_contact) do
    client.client_contacts.create(:client_contact)
  end

  it 'should belongs to clients' do
    client_contact.client.count.should == 1
  end

end


