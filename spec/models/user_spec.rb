require 'rails_helper'
require 'spec_helper'

describe User do

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

  describe User do
    it { should have_and_belong_to_many(:accounts) }
  end

  it 'should recognise when an user has no account' do
    first_user.accounts.count.should == 0
  end

  it 'should handle  user with an account' do
    first_user.accounts << second_account
    first_user.accounts.count.should == 1
  end

  it 'should automatically know a accounts user' do
    first_user.accounts << second_account
    second_account.users.count.should == 1
  end

  it 'should handle  users collaboration with account' do
    first_user.accounts << first_account
    second_user.accounts << first_account

    first_account.users.count.should == 2
  end

  it '#currency_symbol' do
    expect(first_user.currency_symbol).to eq('$')
  end

  it '#currency_code' do
    expect(first_user.currency_code).to eq('USD')
  end

  it '#already_exists?' do
    expect(first_user.already_exists?('umairmunir16@gmail.com')).to eq(false)
  end

  it '#current_account' do
    expect(first_user.current_account).to eq(nil)
  end

end
