class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.integer  "account_id"
      t.string   "company_name"
      t.string   "contact_name"
      t.string   "contact_title"
      t.string   "country"
      t.string   "city"
      t.string   "street_address_1"
      t.string   "street_address_2"
      t.string   "province_or_state"
      t.string   "postal_or_zipcode"
      t.string   "phone_number"
      t.string   "fax_number"
      t.string   "email"
      t.string   "logo"
      t.string   "company_tag_line"
      t.string   "memo"
      t.datetime "created_at",        null: false
      t.datetime "updated_at",        null: false
      t.string   "archive_number"
      t.datetime "archived_at"
      t.datetime "deleted_at"
    end
  end
end
