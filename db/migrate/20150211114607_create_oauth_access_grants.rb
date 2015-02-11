class CreateOauthAccessGrants < ActiveRecord::Migration
  def change
    create_table :oauth_access_grants do |t|
      t.integer  "resource_owner_id", null: false
      t.integer  "application_id",    null: false
      t.string   "token",             null: false
      t.integer  "expires_in",        null: false
      t.text     "redirect_uri",      null: false
      t.datetime "created_at",        null: false
      t.datetime "revoked_at"
      t.string   "scopes"
    end
    add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree
  end
end
