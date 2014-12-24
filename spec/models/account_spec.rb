require 'rails_helper'

describe Account do
  let(:first_user) do
    FactoryGirl.create(:user)
  end

  let(:second_user) do
    FactoryGirl.create(:user)
  end

  let(:first_account) do
    FactoryGirl.create(:account)
  end

  let(:second_account) do
    FactoryGirl.create(:account)
  end


  it { should have_and_belong_to_many(:users) }
  it { should have_many(:company_entities) }
  it { should have_many(:items) }
  it { should have_many(:clients) }
  it { should have_many(:company_email_templates) }
  it { should have_many(:email_templates) }
  it { should have_many(:companies) }


  it 'should recognise when an user has no account' do
    expect(first_user.accounts.count).to eq(0)
  end

  it 'should handle  user with an account' do
    first_user.accounts << second_account
    expect(first_user.accounts.count).to eq(1)
  end

  it 'should automatically know a accounts user' do
    first_user.accounts << second_account
    expect(second_account.users.count).to eq (1)
  end

  it 'should handle  users collaboration with account' do
    first_user.accounts << first_account
    second_user.accounts << first_account
    expect(first_account.users.count).to eq(2)
  end

end
