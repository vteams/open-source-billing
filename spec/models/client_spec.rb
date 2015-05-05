require 'rails_helper'

describe Client do
  let(:client) do
    FactoryGirl.create(:client)
  end

  it { should have_many(:invoices) }
  it { should have_many(:payments) }
  it { should have_many(:client_contacts) }
  it { should accept_nested_attributes_for(:client_contacts) }
  #it { should belong_to(:company) }
  it { should have_many(:company_entities) }

  it "should have many company_entities" do
    t = Client.reflect_on_association(:client_contacts)
    t.macro.should == :has_many
  end


  it '#organization_name' do
    expect(client.organization_name).to eq('Nxb')
  end

  it '#contact_name' do
    expect(client.contact_name).to eq('Umair Munir')
  end

  it '#last_invoice' do
    expect(client.last_invoice).to eq(nil)
  end

  it '#purchase_options' do
    expect(client.purchase_options).to eq({ ip: '10.28.80.144', billing_address: { name: 'Arif Khan', address1: '2nd Street', city: 'Lahore', state: 'Punjab', country: 'Pakistan', zip: '54000' } })
  end


  it '#get_credit_card' do
    expect(client.get_credit_card()).to eq(type: 'visa' , first_name: 'Arif', last_name: 'Khan',  number: '4650161406428289', month: '8',  year: '2015',  verification_value: '123')
  end

  it '#archive_multiple' do
    expect(Client.archive_multiple('Missing "ids"')).to eq([])
  end

  it '#delete_multiple' do
    expect(Client.delete_multiple('Missing "ids"')).to eq([])
  end

  it '#recover_archived' do
    expect(Client.recover_archived('Missing "ids"')).to eq([])
  end

  it '#recover_deleted' do
    expect(Client.recover_deleted('Missing "ids"')).to eq([])
  end

  it '#filter' do
    expect(Client.filter('Missing "params"')).to eq('Exception in RSpec')
  end

  it '#credit_payments' do
    expect(client.credit_payments).to eq([])
  end

  it '#client_credit' do
    expect(client.client_credit).to eq('Returned instance object BigDecimal')
  end

  it '#add_available_credit' do
    expect(client.add_available_credit('Missing "available_credit"', 'Missing "company_id"')).to eq('Returned instance object Payment id: nil, invoice_id: nil, payment_amount: #<BigDecimal:34e0068,"0.0",9(9)>, payment_type: "credit", payment_method: nil, payment_date: "2014-12-02", notes: nil, send_payment_notification: nil, paid_full: nil, archive_number: nil, archived_at: nil, deleted_at: nil, created_at: nil, updated_at: nil, credit_applied: nil, client_id: nil, company_id')
  end

  it '#update_available_credit' do
    expect(client.update_available_credit('Missing "available_credit"')).to eq('Exception in RSpec')
  end

  it '#get_clients' do
    expect(Client.get_clients('Missing "params"')).to eq('Exception in RSpec')
  end
end
