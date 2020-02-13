require 'factory_girl'
require 'faker'
FactoryGirl.define do  factory :introduction do
    user nil
  end
  factory :mail_config do
    address "MyString"
port 1
authentication "MyString"
user_name "MyString"
password "MyString"
enable_starttls_auto false
company nil
  end
  factory :recurring_schedule do
    next_invoice_date "2017-04-18 14:04:42"
frequency "MyString"
occurrences 1
delivery_option "MyString"
invoice_id 1
  end
  factory :stripe_error do
    
  end
  factory :subscription do
    
  end
  factory :plan do
    
  end
  factory :role do
    
  end
  factory :invoice_task do
    name "MyString"
description "MyString"
rate 1
hours 1.5
invoice_id 1
  end

  factory :team_member do
      email "MyString"
      name "MyString"
      rate "9.99"
      archive_number "MyString"
      archived_at "2016-03-03 20:14:12"
      project_id 1
      staff_id 1
  end

  factory :log do
      project_id 1
      task_id 1
      hours 1.5
      notes "MyString"
  end

  factory :project_task do
    name "MyString"
    description "MyText"
    rate 1
    archive_number "MyString"
    archived_at "2016-03-03 13:32:12"
    project_id 1
    task_id 1
  end

  factory :project do
    project_name "MyString"
    client_id 1
    manager_id 1
    billing_method "MyString"
    description "MyText"
    estimate_time 1.5
  end

  factory :task do
      name "MyString"
      description "MyString"
      billable false
      rate "9.99"
  end

  factory :staff do
      email "MyString"
      name "MyString"
      rate "9.99"
      created_by 1
      updated_by 1
  end

  factory :line_item_tax do
    invoice_line_item_id 1
    percentage "9.99"
    name "MyString"
  end

  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :user do
    user_name 'umairmunir'
    email
    password 'password'
  end

  factory :account do
    org_name 'NextBridge'
    country 'Pakistan'
    street_address_1 '2nd Street'
    street_address_2 '3rd Street'
    city 'Lahore'
    province_or_state 'Punjab'
    postal_or_zip_code '54000'
    profession 'It Development'
    phone_business '123'
    phone_mobile '123'
    fax '123'
    email
    time_zone '123'
    auto_dst_adjustment '1'
    currency_code '123'
    currency_symbol '123'
    admin_first_name 'Umair'
    admin_last_name 'Munir'
    admin_email 'umair.munir@nxb.com.pk'
    admin_billing_rate_per_hour 2
    admin_user_name 'umairmunir'
    admin_password 'password'
  end

  factory :client do
    organization_name 'Nxb'
    email
    first_name 'Umair'
    last_name 'Munir'
    home_phone '123'
    mobile_number '123'
    send_invoice_by 'XYZ'
    country 'Pakistan'
    address_street1 '2nd Street'
    address_street2 '3rd Street'
    city 'Lahore'
    province_state 'Punjab'
    postal_zip_code '54000'
    industry 'It Development'
    company_size '123'
    business_phone '123'
    fax '123'
    internal_notes 'Sample Note'
    archive_number '123'
    archived_at Time.now
    available_credit 12.0
  end

  factory :company_entity, class: 'company_entity' do
    association :parent, factory: :account
    association :entity, factory: :client
  end

  factory :client_contact, class:'client_contact' do
   first_name 'Umair'
   last_name 'Munir'
   email
   home_phone '123'
   mobile_number '123'
   archive_number '123'
  end
end


