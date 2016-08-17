# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160817124148) do

  create_table "account_users", force: true do |t|
    t.integer "user_id"
    t.integer "account_id"
  end

  create_table "accounts", force: true do |t|
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

  create_table "api_keys", force: true do |t|
    t.string   "access_token"
    t.datetime "expires_at"
    t.integer  "user_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_keys", ["access_token"], name: "index_api_keys_on_access_token", unique: true, using: :btree
  add_index "api_keys", ["user_id"], name: "index_api_keys_on_user_id", using: :btree

  create_table "categories", force: true do |t|
    t.string   "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "client_contacts", force: true do |t|
    t.integer  "client_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "home_phone"
    t.string   "mobile_number"
    t.string   "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "clients", force: true do |t|
    t.string   "organization_name"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "home_phone"
    t.string   "mobile_number"
    t.string   "send_invoice_by"
    t.string   "country"
    t.string   "address_street1"
    t.string   "address_street2"
    t.string   "city"
    t.string   "province_state"
    t.string   "postal_zip_code"
    t.string   "industry"
    t.string   "company_size"
    t.string   "business_phone"
    t.string   "fax"
    t.text     "internal_notes"
    t.string   "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.decimal  "available_credit",  precision: 8, scale: 2, default: 0.0
    t.integer  "currency_id"
    t.string   "provider"
    t.string   "provider_id"
  end

  create_table "companies", force: true do |t|
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

  create_table "company_email_templates", force: true do |t|
    t.integer  "template_id"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "company_entities", force: true do |t|
    t.integer  "entity_id"
    t.string   "entity_type"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "credit_payments", force: true do |t|
    t.integer  "payment_id"
    t.integer  "invoice_id"
    t.decimal  "amount",     precision: 10, scale: 2
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "credit_id"
  end

  create_table "currencies", force: true do |t|
    t.string   "title"
    t.string   "code"
    t.string   "unit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",             default: 0
    t.integer  "attempts",             default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "recurring_profile_id"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "email_templates", force: true do |t|
    t.string   "template_type"
    t.string   "email_from"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "status"
    t.integer  "torder"
    t.boolean  "send_email",               default: true
    t.integer  "no_of_days"
    t.boolean  "is_late_payment_reminder", default: false
  end

  create_table "estimates", force: true do |t|
    t.string   "estimate_number"
    t.datetime "estimate_date"
    t.string   "po_number"
    t.decimal  "discount_percentage", precision: 10, scale: 2
    t.integer  "client_id"
    t.text     "terms"
    t.text     "notes"
    t.string   "status"
    t.decimal  "sub_total",           precision: 10, scale: 2
    t.decimal  "discount_amount",     precision: 10, scale: 2
    t.decimal  "tax_amount",          precision: 10, scale: 2
    t.decimal  "estimate_total",      precision: 10, scale: 2
    t.string   "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "discount_type"
    t.integer  "company_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "currency_id"
    t.string   "provider"
    t.string   "provider_id"
  end

  create_table "expense_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "provider_id"
  end

  create_table "expenses", force: true do |t|
    t.float    "amount",         limit: 24
    t.datetime "expense_date"
    t.integer  "category_id"
    t.text     "note"
    t.integer  "client_id"
    t.string   "archive_number"
    t.datetime "archived_at"
    t.time     "deleted_at"
    t.integer  "tax_1"
    t.integer  "tax_2"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "provider_id"
  end

  create_table "invoice_line_items", force: true do |t|
    t.integer  "invoice_id"
    t.integer  "item_id"
    t.string   "item_name"
    t.string   "item_description"
    t.decimal  "item_unit_cost",   precision: 10, scale: 2
    t.decimal  "item_quantity",    precision: 10, scale: 2
    t.integer  "tax_1"
    t.integer  "tax_2"
    t.string   "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.decimal  "actual_price",     precision: 10, scale: 2, default: 0.0
    t.integer  "estimate_id"
  end

  create_table "invoice_tasks", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "rate"
    t.float    "hours",       limit: 24
    t.integer  "invoice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", force: true do |t|
    t.string   "invoice_number"
    t.datetime "invoice_date"
    t.string   "po_number"
    t.decimal  "discount_percentage", precision: 10, scale: 2
    t.integer  "client_id"
    t.text     "terms"
    t.text     "notes"
    t.string   "status"
    t.decimal  "sub_total",           precision: 10, scale: 2
    t.decimal  "discount_amount",     precision: 10, scale: 2
    t.decimal  "tax_amount",          precision: 10, scale: 2
    t.decimal  "invoice_total",       precision: 10, scale: 2
    t.string   "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "payment_terms_id"
    t.date     "due_date"
    t.string   "last_invoice_status"
    t.string   "discount_type"
    t.integer  "company_id"
    t.integer  "project_id"
    t.string   "invoice_type"
    t.integer  "currency_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "provider"
    t.string   "provider_id"
  end

  create_table "items", force: true do |t|
    t.string   "item_name"
    t.string   "item_description"
    t.decimal  "unit_cost",        precision: 10, scale: 2
    t.decimal  "quantity",         precision: 10, scale: 2
    t.integer  "tax_1"
    t.integer  "tax_2"
    t.boolean  "track_inventory"
    t.integer  "inventory"
    t.string   "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.decimal  "actual_price",     precision: 10, scale: 2, default: 0.0
    t.string   "provider"
    t.string   "provider_id"
  end

  create_table "line_item_taxes", force: true do |t|
    t.integer  "invoice_line_item_id"
    t.decimal  "percentage",           precision: 10, scale: 0
    t.string   "name"
    t.integer  "tax_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
  end

  create_table "logs", force: true do |t|
    t.integer  "project_id"
    t.integer  "task_id"
    t.float    "hours",       limit: 24
    t.string   "notes"
    t.date     "date"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "provider_id"
    t.integer  "user_id"
  end

  create_table "oauth_access_grants", force: true do |t|
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

  create_table "oauth_access_tokens", force: true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: true do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "payment_terms", force: true do |t|
    t.integer  "number_of_days"
    t.string   "description"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "payments", force: true do |t|
    t.integer  "invoice_id"
    t.decimal  "payment_amount",            precision: 8,  scale: 2
    t.string   "payment_type"
    t.string   "payment_method"
    t.date     "payment_date"
    t.text     "notes"
    t.boolean  "send_payment_notification"
    t.boolean  "paid_full"
    t.string   "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.decimal  "credit_applied",            precision: 10, scale: 2
    t.integer  "client_id"
    t.integer  "company_id"
    t.string   "status"
    t.string   "provider"
    t.string   "provider_id"
  end

  create_table "project_tasks", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.float    "rate",           limit: 24
    t.string   "archive_number"
    t.datetime "archived_at"
    t.integer  "project_id"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", force: true do |t|
    t.string   "project_name"
    t.integer  "client_id"
    t.integer  "manager_id"
    t.string   "billing_method"
    t.text     "description"
    t.integer  "total_hours"
    t.integer  "company_id"
    t.integer  "updated_by"
    t.integer  "created_by"
    t.string   "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "provider_id"
  end

  create_table "recurring_profile_line_items", force: true do |t|
    t.integer  "recurring_profile_id"
    t.integer  "item_id"
    t.string   "item_name"
    t.string   "item_description"
    t.decimal  "item_unit_cost",       precision: 10, scale: 2
    t.decimal  "item_quantity",        precision: 10, scale: 2
    t.integer  "tax_1"
    t.integer  "tax_2"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
  end

  create_table "recurring_profiles", force: true do |t|
    t.datetime "first_invoice_date"
    t.string   "po_number"
    t.decimal  "discount_percentage", precision: 10, scale: 2
    t.string   "frequency"
    t.integer  "occurrences"
    t.boolean  "prorate"
    t.decimal  "prorate_for",         precision: 10, scale: 2
    t.integer  "gateway_id"
    t.integer  "client_id"
    t.text     "notes"
    t.string   "status"
    t.decimal  "sub_total",           precision: 10, scale: 2
    t.decimal  "discount_amount",     precision: 10, scale: 2
    t.decimal  "tax_amount",          precision: 10, scale: 2
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "invoice_number"
    t.string   "discount_type"
    t.decimal  "invoice_total",       precision: 10, scale: 2
    t.string   "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.integer  "payment_terms_id"
    t.integer  "company_id"
    t.string   "last_invoice_status"
    t.datetime "last_sent_date"
    t.integer  "sent_invoices"
    t.integer  "currency_id"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "sent_emails", force: true do |t|
    t.date     "date"
    t.string   "sender"
    t.string   "recipient"
    t.string   "type"
    t.string   "subject"
    t.text     "content"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "notification_id"
    t.string   "notification_type"
    t.integer  "company_id"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "settings", force: true do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "staffs", force: true do |t|
    t.string   "email"
    t.string   "name"
    t.float    "rate",           limit: 24
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "archive_number"
    t.datetime "archived_at"
    t.time     "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.string   "provider"
    t.string   "provider_id"
    t.integer  "user_id"
  end

  create_table "tasks", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "billable"
    t.float    "rate",           limit: 24
    t.string   "archive_number"
    t.datetime "archived_at"
    t.time     "deleted_at"
    t.integer  "updated_by"
    t.integer  "created_by"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "provider_id"
  end

  create_table "taxes", force: true do |t|
    t.string   "name"
    t.decimal  "percentage",     precision: 10, scale: 2
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.string   "provider"
    t.string   "provider_id"
  end

  create_table "team_members", force: true do |t|
    t.string   "email"
    t.string   "name"
    t.float    "rate",           limit: 24
    t.string   "archive_number"
    t.datetime "archived_at"
    t.integer  "project_id"
    t.integer  "staff_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
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

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
