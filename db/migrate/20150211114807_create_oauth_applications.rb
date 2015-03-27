class CreateOauthApplications < ActiveRecord::Migration
  def change
    create_table :oauth_applications do |t|
      t.string   "name",         null: false
      t.string   "uid",          null: false
      t.string   "secret",       null: false
      t.text     "redirect_uri", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree
  end
end
