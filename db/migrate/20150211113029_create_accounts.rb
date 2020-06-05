class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts, force: true do |t|
      t.string   "org_name"
      t.string   "country"
      t.string   "street_address_1"
      t.string   "street_address_2"
      t.string   "city"
      t.string   "province_or_state"
      t.string   "postal_or_zip_code"
      t.string   "profession"
      t.string   "phone_business"
      t.string   "phone_mobile"
      t.string   "fax"
      t.string   "email"
      t.string   "time_zone"
      t.boolean  "auto_dst_adjustment"
      t.string   "currency_code"
      t.string   "currency_symbol"
      t.string   "admin_first_name"
      t.string   "admin_last_name"
      t.string   "admin_email"
      t.decimal  "admin_billing_rate_per_hour", precision: 10, scale: 0
      t.string   "admin_user_name"
      t.string   "admin_password"
      t.datetime "created_at",                                           null: false
      t.datetime "updated_at",                                           null: false
    end
  end
end
