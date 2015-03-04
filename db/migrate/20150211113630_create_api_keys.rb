class CreateApiKeys < ActiveRecord::Migration
  def self.up
    unless table_exists? :api_keys
      create_table :api_keys do |t|
        t.string   "access_token"
        t.datetime "expires_at"
        t.integer  "user_id"
        t.boolean  "active"
        t.datetime "created_at"
        t.datetime "updated_at"
      end
      add_index "api_keys", ["access_token"], name: "index_api_keys_on_access_token", unique: true, using: :btree
      add_index "api_keys", ["user_id"], name: "index_api_keys_on_user_id", using: :btree
    end
  end

  def self.down
    drop_table :api_keys if table_exists? :api_keys
  end
end
