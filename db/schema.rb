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

ActiveRecord::Schema.define(version: 20200106091339) do

  create_table "account_users", force: :cascade do |t|
    t.integer "user_id",    limit: 4
    t.integer "account_id", limit: 4
  end

  create_table "accounts", force: :cascade do |t|
    t.string   "org_name",                    limit: 255
    t.string   "country",                     limit: 255
    t.string   "street_address_1",            limit: 255
    t.string   "street_address_2",            limit: 255
    t.string   "city",                        limit: 255
    t.string   "province_or_state",           limit: 255
    t.string   "postal_or_zip_code",          limit: 255
    t.string   "profession",                  limit: 255
    t.string   "phone_business",              limit: 255
    t.string   "phone_mobile",                limit: 255
    t.string   "fax",                         limit: 255
    t.string   "email",                       limit: 255
    t.string   "time_zone",                   limit: 255
    t.boolean  "auto_dst_adjustment"
    t.string   "currency_code",               limit: 255
    t.string   "currency_symbol",             limit: 255
    t.string   "admin_first_name",            limit: 255
    t.string   "admin_last_name",             limit: 255
    t.string   "admin_email",                 limit: 255
    t.decimal  "admin_billing_rate_per_hour",             precision: 10
    t.string   "admin_user_name",             limit: 255
    t.string   "admin_password",              limit: 255
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id",   limit: 4
    t.string   "trackable_type", limit: 255
    t.integer  "owner_id",       limit: 4
    t.string   "owner_type",     limit: 255
    t.string   "key",            limit: 255
    t.text     "parameters",     limit: 65535
    t.integer  "recipient_id",   limit: 4
    t.string   "recipient_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_read",                      default: false
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "api_keys", force: :cascade do |t|
    t.string   "access_token", limit: 255
    t.datetime "expires_at"
    t.integer  "user_id",      limit: 4
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_keys", ["access_token"], name: "index_api_keys_on_access_token", unique: true, using: :btree
  add_index "api_keys", ["user_id"], name: "index_api_keys_on_user_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "category",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "client_contacts", force: :cascade do |t|
    t.integer  "client_id",      limit: 4
    t.string   "first_name",     limit: 255
    t.string   "last_name",      limit: 255
    t.string   "email",          limit: 255
    t.string   "home_phone",     limit: 255
    t.string   "mobile_number",  limit: 255
    t.string   "archive_number", limit: 255
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "clients", force: :cascade do |t|
    t.string   "organization_name",      limit: 255
    t.string   "email",                  limit: 255
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "home_phone",             limit: 255
    t.string   "mobile_number",          limit: 255
    t.string   "send_invoice_by",        limit: 255
    t.string   "country",                limit: 255
    t.string   "address_street1",        limit: 255
    t.string   "address_street2",        limit: 255
    t.string   "city",                   limit: 255
    t.string   "province_state",         limit: 255
    t.string   "postal_zip_code",        limit: 255
    t.string   "industry",               limit: 255
    t.string   "company_size",           limit: 255
    t.string   "business_phone",         limit: 255
    t.string   "fax",                    limit: 255
    t.text     "internal_notes",         limit: 65535
    t.string   "archive_number",         limit: 255
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                                                                 null: false
    t.datetime "updated_at",                                                                 null: false
    t.decimal  "available_credit",                     precision: 8, scale: 2, default: 0.0
    t.integer  "currency_id",            limit: 4
    t.string   "provider",               limit: 255
    t.string   "provider_id",            limit: 255
    t.string   "billing_email",          limit: 255
    t.string   "vat_number",             limit: 255
    t.string   "encrypted_password",     limit: 255,                           default: "",  null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,                             default: 0,   null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
  end

  add_index "clients", ["email"], name: "index_clients_on_email", unique: true, using: :btree
  add_index "clients", ["reset_password_token"], name: "index_clients_on_reset_password_token", unique: true, using: :btree

  create_table "companies", force: :cascade do |t|
    t.integer  "account_id",        limit: 4
    t.string   "company_name",      limit: 255
    t.string   "contact_name",      limit: 255
    t.string   "contact_title",     limit: 255
    t.string   "country",           limit: 255
    t.string   "city",              limit: 255
    t.string   "street_address_1",  limit: 255
    t.string   "street_address_2",  limit: 255
    t.string   "province_or_state", limit: 255
    t.string   "postal_or_zipcode", limit: 255
    t.string   "phone_number",      limit: 255
    t.string   "fax_number",        limit: 255
    t.string   "email",             limit: 255
    t.string   "logo",              limit: 255
    t.string   "company_tag_line",  limit: 255
    t.string   "memo",              limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "archive_number",    limit: 255
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.integer  "base_currency_id",  limit: 4,   default: 1
    t.string   "color_code",        limit: 255
    t.string   "abbreviation",      limit: 255
  end

  create_table "companies_users", id: false, force: :cascade do |t|
    t.integer "user_id",    limit: 4
    t.integer "company_id", limit: 4
  end

  create_table "company_email_templates", force: :cascade do |t|
    t.integer  "template_id", limit: 4
    t.integer  "parent_id",   limit: 4
    t.string   "parent_type", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "company_entities", force: :cascade do |t|
    t.integer  "entity_id",   limit: 4
    t.string   "entity_type", limit: 255
    t.integer  "parent_id",   limit: 4
    t.string   "parent_type", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "credit_payments", force: :cascade do |t|
    t.integer  "payment_id", limit: 4
    t.integer  "invoice_id", limit: 4
    t.decimal  "amount",               precision: 10, scale: 2
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "credit_id",  limit: 4
  end

  create_table "currencies", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.string   "code",       limit: 255
    t.string   "unit",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",             limit: 4,     default: 0
    t.integer  "attempts",             limit: 4,     default: 0
    t.text     "handler",              limit: 65535
    t.text     "last_error",           limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",            limit: 255
    t.string   "queue",                limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "recurring_profile_id", limit: 4
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "email_templates", force: :cascade do |t|
    t.string   "template_type",            limit: 255
    t.string   "email_from",               limit: 255
    t.string   "subject",                  limit: 255
    t.text     "body",                     limit: 65535
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "status",                   limit: 255
    t.integer  "torder",                   limit: 4
    t.boolean  "send_email",                             default: true
    t.integer  "no_of_days",               limit: 4
    t.boolean  "is_late_payment_reminder",               default: false
    t.string   "cc",                       limit: 255
    t.string   "bcc",                      limit: 255
  end

  create_table "estimates", force: :cascade do |t|
    t.string   "estimate_number",     limit: 255
    t.datetime "estimate_date"
    t.string   "po_number",           limit: 255
    t.decimal  "discount_percentage",               precision: 10, scale: 2
    t.integer  "client_id",           limit: 4
    t.text     "terms",               limit: 65535
    t.text     "notes",               limit: 65535
    t.string   "status",              limit: 255
    t.decimal  "sub_total",                         precision: 10, scale: 2
    t.decimal  "discount_amount",                   precision: 10, scale: 2
    t.decimal  "tax_amount",                        precision: 10, scale: 2
    t.decimal  "estimate_total",                    precision: 10, scale: 2
    t.string   "archive_number",      limit: 255
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.string   "discount_type",       limit: 255
    t.integer  "company_id",          limit: 4
    t.integer  "created_by",          limit: 4
    t.integer  "updated_by",          limit: 4
    t.integer  "currency_id",         limit: 4
    t.string   "provider",            limit: 255
    t.string   "provider_id",         limit: 255
    t.decimal  "estimate_tax_amount",               precision: 10, scale: 2
    t.integer  "tax_id",              limit: 4
  end

  create_table "expense_categories", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider",    limit: 255
    t.string   "provider_id", limit: 255
  end

  create_table "expenses", force: :cascade do |t|
    t.float    "amount",         limit: 24
    t.datetime "expense_date"
    t.integer  "category_id",    limit: 4
    t.text     "note",           limit: 65535
    t.integer  "client_id",      limit: 4
    t.string   "archive_number", limit: 255
    t.datetime "archived_at"
    t.time     "deleted_at"
    t.integer  "tax_1",          limit: 4
    t.integer  "tax_2",          limit: 4
    t.integer  "company_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider",       limit: 255
    t.string   "provider_id",    limit: 255
  end

  create_table "introductions", force: :cascade do |t|
    t.boolean  "dashboard",                default: false
    t.boolean  "invoice",                  default: false
    t.boolean  "new_invoice",              default: false
    t.boolean  "estimate",                 default: false
    t.boolean  "new_estimate",             default: false
    t.boolean  "payment",                  default: false
    t.boolean  "new_payment",              default: false
    t.boolean  "client",                   default: false
    t.boolean  "new_client",               default: false
    t.boolean  "item",                     default: false
    t.boolean  "new_item",                 default: false
    t.boolean  "tax",                      default: false
    t.boolean  "new_tax",                  default: false
    t.boolean  "report",                   default: false
    t.boolean  "setting",                  default: false
    t.boolean  "invoice_table",            default: false
    t.boolean  "estimate_table",           default: false
    t.boolean  "payment_table",            default: false
    t.boolean  "client_table",             default: false
    t.boolean  "item_table",               default: false
    t.boolean  "tax_table",                default: false
    t.integer  "user_id",        limit: 4
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "introductions", ["user_id"], name: "index_introductions_on_user_id", using: :btree

  create_table "invoice_line_items", force: :cascade do |t|
    t.integer  "invoice_id",       limit: 4
    t.integer  "item_id",          limit: 4
    t.string   "item_name",        limit: 255
    t.string   "item_description", limit: 255
    t.decimal  "item_unit_cost",               precision: 10, scale: 2
    t.decimal  "item_quantity",                precision: 10, scale: 2
    t.integer  "tax_1",            limit: 4
    t.integer  "tax_2",            limit: 4
    t.string   "archive_number",   limit: 255
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.decimal  "actual_price",                 precision: 10, scale: 2, default: 0.0
    t.integer  "estimate_id",      limit: 4
  end

  create_table "invoice_tasks", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.integer  "rate",        limit: 4
    t.float    "hours",       limit: 24
    t.integer  "invoice_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", force: :cascade do |t|
    t.string   "invoice_number",                 limit: 255
    t.datetime "invoice_date"
    t.string   "po_number",                      limit: 255
    t.decimal  "discount_percentage",                          precision: 15, scale: 3
    t.integer  "client_id",                      limit: 4
    t.text     "terms",                          limit: 65535
    t.text     "notes",                          limit: 65535
    t.string   "status",                         limit: 255
    t.decimal  "sub_total",                                    precision: 15, scale: 3
    t.decimal  "discount_amount",                              precision: 15, scale: 3
    t.decimal  "tax_amount",                                   precision: 15, scale: 3
    t.decimal  "invoice_total",                                precision: 15, scale: 3
    t.string   "archive_number",                 limit: 255
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                                                                            null: false
    t.datetime "updated_at",                                                                            null: false
    t.integer  "payment_terms_id",               limit: 4
    t.date     "due_date"
    t.string   "last_invoice_status",            limit: 255
    t.string   "discount_type",                  limit: 255
    t.integer  "company_id",                     limit: 4
    t.integer  "project_id",                     limit: 4
    t.string   "invoice_type",                   limit: 255
    t.integer  "currency_id",                    limit: 4
    t.integer  "created_by",                     limit: 4
    t.integer  "updated_by",                     limit: 4
    t.string   "provider",                       limit: 255
    t.string   "provider_id",                    limit: 255
    t.integer  "tax_id",                         limit: 4
    t.decimal  "invoice_tax_amount",                           precision: 10, scale: 2
    t.integer  "parent_id",                      limit: 4
    t.integer  "base_currency_id",               limit: 4,                              default: 1
    t.float    "conversion_rate",                limit: 24,                             default: 1.0
    t.float    "base_currency_equivalent_total", limit: 24
    t.boolean  "is_compact",                                                            default: false
    t.string   "batch_number",                   limit: 255
    t.integer  "batch_id",                       limit: 4
    t.boolean  "is_batched"
  end

  create_table "items", force: :cascade do |t|
    t.string   "item_name",        limit: 255
    t.string   "item_description", limit: 255
    t.decimal  "unit_cost",                    precision: 10, scale: 2
    t.decimal  "quantity",                     precision: 10, scale: 2
    t.integer  "tax_1",            limit: 4
    t.integer  "tax_2",            limit: 4
    t.boolean  "track_inventory"
    t.integer  "inventory",        limit: 4
    t.string   "archive_number",   limit: 255
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.decimal  "actual_price",                 precision: 10, scale: 2, default: 0.0
    t.string   "provider",         limit: 255
    t.string   "provider_id",      limit: 255
  end

  create_table "line_item_taxes", force: :cascade do |t|
    t.integer  "invoice_line_item_id", limit: 4
    t.decimal  "percentage",                       precision: 10
    t.string   "name",                 limit: 255
    t.integer  "tax_id",               limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "archive_number",       limit: 255
    t.datetime "archived_at"
    t.datetime "deleted_at"
  end

  create_table "logs", force: :cascade do |t|
    t.integer  "project_id",  limit: 4
    t.integer  "task_id",     limit: 4
    t.float    "hours",       limit: 24
    t.string   "notes",       limit: 255
    t.date     "date"
    t.integer  "company_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider",    limit: 255
    t.string   "provider_id", limit: 255
    t.integer  "user_id",     limit: 4
  end

  create_table "mail_configs", force: :cascade do |t|
    t.string   "address",              limit: 255
    t.integer  "port",                 limit: 4
    t.string   "authentication",       limit: 255
    t.string   "user_name",            limit: 255
    t.string   "password",             limit: 255
    t.boolean  "enable_starttls_auto"
    t.integer  "company_id",           limit: 4
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "from",                 limit: 255
    t.string   "openssl_verify_mode",  limit: 255
    t.boolean  "tls",                              default: true
  end

  add_index "mail_configs", ["company_id"], name: "index_mail_configs_on_company_id", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4,     null: false
    t.integer  "application_id",    limit: 4,     null: false
    t.string   "token",             limit: 255,   null: false
    t.integer  "expires_in",        limit: 4,     null: false
    t.text     "redirect_uri",      limit: 65535, null: false
    t.datetime "created_at",                      null: false
    t.datetime "revoked_at"
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4
    t.integer  "application_id",    limit: 4
    t.string   "token",             limit: 255, null: false
    t.string   "refresh_token",     limit: 255
    t.integer  "expires_in",        limit: 4
    t.datetime "revoked_at"
    t.datetime "created_at",                    null: false
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",         limit: 255,                null: false
    t.string   "uid",          limit: 255,                null: false
    t.string   "secret",       limit: 255,                null: false
    t.text     "redirect_uri", limit: 65535,              null: false
    t.string   "scopes",       limit: 255,   default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "payment_terms", force: :cascade do |t|
    t.integer  "number_of_days", limit: 4
    t.string   "description",    limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "invoice_id",                limit: 4
    t.decimal  "payment_amount",                          precision: 15, scale: 3
    t.string   "payment_type",              limit: 255
    t.string   "payment_method",            limit: 255
    t.date     "payment_date"
    t.text     "notes",                     limit: 65535
    t.boolean  "send_payment_notification"
    t.boolean  "paid_full"
    t.string   "archive_number",            limit: 255
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.decimal  "credit_applied",                          precision: 15, scale: 3
    t.integer  "client_id",                 limit: 4
    t.integer  "company_id",                limit: 4
    t.string   "status",                    limit: 255
    t.string   "provider",                  limit: 255
    t.string   "provider_id",               limit: 255
    t.integer  "currency_id",               limit: 4
    t.integer  "created_by",                limit: 4
    t.integer  "updated_by",                limit: 4
  end

  create_table "permissions", force: :cascade do |t|
    t.boolean  "can_create"
    t.boolean  "can_update"
    t.boolean  "can_delete"
    t.boolean  "can_read"
    t.string   "entity_type", limit: 255
    t.integer  "role_id",     limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "permissions", ["role_id"], name: "index_permissions_on_role_id", using: :btree

  create_table "project_tasks", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.text     "description",    limit: 65535
    t.float    "rate",           limit: 24
    t.string   "archive_number", limit: 255
    t.datetime "archived_at"
    t.integer  "project_id",     limit: 4
    t.integer  "task_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start_date"
    t.datetime "due_date"
    t.float    "hours",          limit: 24
    t.float    "spent_time",     limit: 24
  end

  create_table "projects", force: :cascade do |t|
    t.string   "project_name",   limit: 255
    t.integer  "client_id",      limit: 4
    t.integer  "manager_id",     limit: 4
    t.string   "billing_method", limit: 255
    t.text     "description",    limit: 65535
    t.integer  "total_hours",    limit: 4
    t.integer  "company_id",     limit: 4
    t.integer  "updated_by",     limit: 4
    t.integer  "created_by",     limit: 4
    t.string   "archive_number", limit: 255
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider",       limit: 255
    t.string   "provider_id",    limit: 255
  end

  create_table "recurring_profile_line_items", force: :cascade do |t|
    t.integer  "recurring_profile_id", limit: 4
    t.integer  "item_id",              limit: 4
    t.string   "item_name",            limit: 255
    t.string   "item_description",     limit: 255
    t.decimal  "item_unit_cost",                   precision: 10, scale: 2
    t.decimal  "item_quantity",                    precision: 10, scale: 2
    t.integer  "tax_1",                limit: 4
    t.integer  "tax_2",                limit: 4
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.string   "archive_number",       limit: 255
    t.datetime "archived_at"
    t.datetime "deleted_at"
  end

  create_table "recurring_profiles", force: :cascade do |t|
    t.datetime "first_invoice_date"
    t.string   "po_number",           limit: 255
    t.decimal  "discount_percentage",               precision: 10, scale: 2
    t.string   "frequency",           limit: 255
    t.integer  "occurrences",         limit: 4
    t.boolean  "prorate"
    t.decimal  "prorate_for",                       precision: 10, scale: 2
    t.integer  "gateway_id",          limit: 4
    t.integer  "client_id",           limit: 4
    t.text     "notes",               limit: 65535
    t.string   "status",              limit: 255
    t.decimal  "sub_total",                         precision: 10, scale: 2
    t.decimal  "discount_amount",                   precision: 10, scale: 2
    t.decimal  "tax_amount",                        precision: 10, scale: 2
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.string   "invoice_number",      limit: 255
    t.string   "discount_type",       limit: 255
    t.decimal  "invoice_total",                     precision: 10, scale: 2
    t.string   "archive_number",      limit: 255
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.integer  "payment_terms_id",    limit: 4
    t.integer  "company_id",          limit: 4
    t.string   "last_invoice_status", limit: 255
    t.datetime "last_sent_date"
    t.integer  "sent_invoices",       limit: 4
    t.integer  "currency_id",         limit: 4
    t.integer  "created_by",          limit: 4
    t.integer  "updated_by",          limit: 4
  end

  create_table "recurring_schedules", force: :cascade do |t|
    t.datetime "next_invoice_date"
    t.string   "frequency",         limit: 255
    t.integer  "occurrences",       limit: 4,   default: 0
    t.string   "delivery_option",   limit: 255
    t.integer  "invoice_id",        limit: 4
    t.integer  "generated_count",   limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enable_recurring",              default: true
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "resource_id",   limit: 4
    t.string   "resource_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "sent_emails", force: :cascade do |t|
    t.date     "date"
    t.string   "sender",            limit: 255
    t.string   "recipient",         limit: 255
    t.string   "type",              limit: 255
    t.string   "subject",           limit: 255
    t.text     "content",           limit: 65535
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "notification_id",   limit: 4
    t.string   "notification_type", limit: 255
    t.integer  "company_id",        limit: 4
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "var",        limit: 255,   null: false
    t.text     "value",      limit: 65535
    t.integer  "thing_id",   limit: 4
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "staffs", force: :cascade do |t|
    t.string   "email",          limit: 255
    t.string   "name",           limit: 255
    t.float    "rate",           limit: 24
    t.integer  "created_by",     limit: 4
    t.integer  "updated_by",     limit: 4
    t.string   "archive_number", limit: 255
    t.datetime "archived_at"
    t.time     "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id",     limit: 4
    t.string   "provider",       limit: 255
    t.string   "provider_id",    limit: 255
    t.integer  "user_id",        limit: 4
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.text     "description",    limit: 65535
    t.boolean  "billable"
    t.float    "rate",           limit: 24
    t.string   "archive_number", limit: 255
    t.datetime "archived_at"
    t.time     "deleted_at"
    t.integer  "updated_by",     limit: 4
    t.integer  "created_by",     limit: 4
    t.integer  "project_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider",       limit: 255
    t.string   "provider_id",    limit: 255
  end

  create_table "taxes", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.decimal  "percentage",                 precision: 10, scale: 2
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "archive_number", limit: 255
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.string   "provider",       limit: 255
    t.string   "provider_id",    limit: 255
  end

  create_table "team_members", force: :cascade do |t|
    t.string   "email",          limit: 255
    t.string   "name",           limit: 255
    t.float    "rate",           limit: 24
    t.string   "archive_number", limit: 255
    t.datetime "archived_at"
    t.integer  "project_id",     limit: 4
    t.integer  "staff_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                     limit: 255, default: "",    null: false
    t.string   "encrypted_password",        limit: 255, default: "",    null: false
    t.string   "reset_password_token",      limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",        limit: 255
    t.string   "last_sign_in_ip",           limit: 255
    t.string   "confirmation_token",        limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",         limit: 255
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "password_salt",             limit: 255
    t.string   "user_name",                 limit: 255
    t.integer  "current_company",           limit: 4
    t.string   "authentication_token",      limit: 255
    t.string   "avatar",                    limit: 255
    t.integer  "role_id",                   limit: 4
    t.boolean  "have_all_companies_access",             default: false
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255,   null: false
    t.integer  "item_id",    limit: 4,     null: false
    t.string   "event",      limit: 255,   null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object",     limit: 65535
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  add_foreign_key "introductions", "users"
  add_foreign_key "mail_configs", "companies"
  add_foreign_key "permissions", "roles"
  add_foreign_key "users", "roles"
end
