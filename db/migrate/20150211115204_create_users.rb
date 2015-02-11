class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   "email",                  default: "", null: false
      t.string   "encrypted_password",     default: "", null: false
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",          default: 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.string   "confirmation_token"
      t.datetime "confirmed_at"
      t.datetime "confirmation_sent_at"
      t.string   "unconfirmed_email"
      t.datetime "created_at",                          null: false
      t.datetime "updated_at",                          null: false
      t.string   "password_salt"
      t.string   "user_name"
      t.integer  "current_company"
      t.string   "authentication_token"
    end
    add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
    add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end
end
