# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_26_104143) do

  create_table "account_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "account_id"
  end

  create_table "accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "org_name"
    t.string "country"
    t.string "street_address_1"
    t.string "street_address_2"
    t.string "city"
    t.string "province_or_state"
    t.string "postal_or_zip_code"
    t.string "profession"
    t.string "phone_business"
    t.string "phone_mobile"
    t.string "fax"
    t.string "email"
    t.string "time_zone"
    t.boolean "auto_dst_adjustment"
    t.string "currency_code"
    t.string "currency_symbol"
    t.string "admin_first_name"
    t.string "admin_last_name"
    t.string "admin_email"
    t.decimal "admin_billing_rate_per_hour", precision: 10
    t.string "admin_user_name"
    t.string "admin_password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "activities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "trackable_type"
    t.bigint "trackable_id"
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.bigint "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_read", default: false
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner_type_and_owner_id"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
  end

  create_table "api_keys", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "access_token"
    t.datetime "expires_at"
    t.integer "user_id"
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["access_token"], name: "index_api_keys_on_access_token", unique: true
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "client_contacts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "client_id"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "home_phone"
    t.string "mobile_number"
    t.string "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clients", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "organization_name"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "home_phone"
    t.string "mobile_number"
    t.string "send_invoice_by"
    t.string "country"
    t.string "address_street1"
    t.string "address_street2"
    t.string "city"
    t.string "province_state"
    t.string "postal_zip_code"
    t.string "industry"
    t.string "company_size"
    t.string "business_phone"
    t.string "fax"
    t.text "internal_notes"
    t.string "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "available_credit", precision: 8, scale: 2, default: "0.0"
    t.integer "currency_id"
    t.string "provider"
    t.string "provider_id"
    t.string "billing_email"
    t.string "vat_number"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.bigint "role_id"
    t.index ["email"], name: "index_clients_on_email", unique: true
    t.index ["reset_password_token"], name: "index_clients_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_clients_on_role_id"
  end

  create_table "companies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "account_id"
    t.string "company_name"
    t.string "contact_name"
    t.string "contact_title"
    t.string "country"
    t.string "city"
    t.string "street_address_1"
    t.string "street_address_2"
    t.string "province_or_state"
    t.string "postal_or_zipcode"
    t.string "phone_number"
    t.string "fax_number"
    t.string "email"
    t.string "logo"
    t.string "company_tag_line"
    t.string "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.integer "base_currency_id", default: 1
    t.string "abbreviation"
    t.string "default_note"
    t.integer "due_date_period"
  end

  create_table "companies_users", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "company_id"
    t.index ["company_id"], name: "index_companies_users_on_company_id"
    t.index ["user_id"], name: "index_companies_users_on_user_id"
  end

  create_table "company_email_templates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "template_id"
    t.integer "parent_id"
    t.string "parent_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "company_entities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "entity_id"
    t.string "entity_type"
    t.integer "parent_id"
    t.string "parent_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "credit_payments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "payment_id"
    t.integer "invoice_id"
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "credit_id"
  end

  create_table "currencies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.string "code"
    t.string "unit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "recurring_profile_id"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "email_templates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "template_type"
    t.string "email_from"
    t.string "subject"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.integer "torder"
    t.boolean "send_email", default: true
    t.integer "no_of_days"
    t.boolean "is_late_payment_reminder", default: false
    t.string "cc"
    t.string "bcc"
  end

  create_table "estimates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "estimate_number"
    t.datetime "estimate_date"
    t.string "po_number"
    t.decimal "discount_percentage", precision: 10, scale: 2
    t.integer "client_id"
    t.text "terms"
    t.text "notes"
    t.string "status"
    t.decimal "sub_total", precision: 10, scale: 2
    t.decimal "discount_amount", precision: 10, scale: 2
    t.decimal "tax_amount", precision: 10, scale: 2
    t.decimal "estimate_total", precision: 10, scale: 2
    t.string "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "discount_type"
    t.integer "company_id"
    t.integer "created_by"
    t.integer "updated_by"
    t.integer "currency_id"
    t.string "provider"
    t.string "provider_id"
    t.decimal "estimate_tax_amount", precision: 10, scale: 2
    t.integer "tax_id"
  end

  create_table "expense_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "provider_id"
  end

  create_table "expenses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.float "amount"
    t.datetime "expense_date"
    t.integer "category_id"
    t.text "note"
    t.integer "client_id"
    t.string "archive_number"
    t.datetime "archived_at"
    t.time "deleted_at"
    t.integer "tax_1"
    t.integer "tax_2"
    t.integer "company_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "provider_id"
  end

  create_table "introductions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.boolean "dashboard", default: false
    t.boolean "invoice", default: false
    t.boolean "new_invoice", default: false
    t.boolean "estimate", default: false
    t.boolean "new_estimate", default: false
    t.boolean "payment", default: false
    t.boolean "new_payment", default: false
    t.boolean "client", default: false
    t.boolean "new_client", default: false
    t.boolean "item", default: false
    t.boolean "new_item", default: false
    t.boolean "tax", default: false
    t.boolean "new_tax", default: false
    t.boolean "report", default: false
    t.boolean "setting", default: false
    t.boolean "invoice_table", default: false
    t.boolean "estimate_table", default: false
    t.boolean "payment_table", default: false
    t.boolean "client_table", default: false
    t.boolean "item_table", default: false
    t.boolean "tax_table", default: false
    t.bigint "user_id"
    t.bigint "client_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_id"], name: "index_introductions_on_client_id"
    t.index ["user_id"], name: "index_introductions_on_user_id"
  end

  create_table "invoice_line_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "invoice_id"
    t.integer "item_id"
    t.string "item_name"
    t.string "item_description"
    t.decimal "item_unit_cost", precision: 10, scale: 2
    t.decimal "item_quantity", precision: 10, scale: 2
    t.integer "tax_1"
    t.integer "tax_2"
    t.string "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "actual_price", precision: 10, scale: 2, default: "0.0"
    t.integer "estimate_id"
  end

  create_table "invoice_tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "rate"
    t.float "hours"
    t.integer "invoice_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "invoices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "invoice_number"
    t.datetime "invoice_date"
    t.string "po_number"
    t.decimal "discount_percentage", precision: 10, scale: 2
    t.integer "client_id"
    t.text "terms"
    t.text "notes"
    t.string "status"
    t.decimal "sub_total", precision: 10, scale: 2
    t.decimal "discount_amount", precision: 10, scale: 2
    t.decimal "tax_amount", precision: 10, scale: 2
    t.decimal "invoice_total", precision: 10, scale: 2
    t.string "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "payment_terms_id"
    t.date "due_date"
    t.string "last_invoice_status"
    t.string "discount_type"
    t.integer "company_id"
    t.integer "project_id"
    t.string "invoice_type"
    t.integer "currency_id"
    t.integer "created_by"
    t.integer "updated_by"
    t.string "provider"
    t.string "provider_id"
    t.integer "tax_id"
    t.decimal "invoice_tax_amount", precision: 10, scale: 2
    t.integer "parent_id"
    t.integer "base_currency_id", default: 1
    t.float "conversion_rate", default: 1.0
    t.float "base_currency_equivalent_total"
    t.string "billing_month"
  end

  create_table "items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "item_name"
    t.string "item_description"
    t.decimal "unit_cost", precision: 10, scale: 2
    t.decimal "quantity", precision: 10, scale: 2
    t.integer "tax_1"
    t.integer "tax_2"
    t.boolean "track_inventory"
    t.integer "inventory"
    t.string "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "actual_price", precision: 10, scale: 2, default: "0.0"
    t.string "provider"
    t.string "provider_id"
  end

  create_table "line_item_taxes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "invoice_line_item_id"
    t.decimal "percentage", precision: 10
    t.string "name"
    t.integer "tax_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
  end

  create_table "logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "project_id"
    t.integer "task_id"
    t.float "hours"
    t.string "notes"
    t.date "date"
    t.integer "company_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "provider_id"
    t.integer "user_id"
  end

  create_table "mail_configs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "address"
    t.integer "port"
    t.string "authentication"
    t.string "user_name"
    t.string "password"
    t.boolean "enable_starttls_auto"
    t.bigint "company_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "from"
    t.string "openssl_verify_mode"
    t.boolean "tls", default: true
    t.index ["company_id"], name: "index_mail_configs_on_company_id"
  end

  create_table "oauth_access_grants", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "payment_terms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "number_of_days"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "invoice_id"
    t.decimal "payment_amount", precision: 15, scale: 3
    t.string "payment_type"
    t.string "payment_method"
    t.date "payment_date"
    t.text "notes"
    t.boolean "send_payment_notification"
    t.boolean "paid_full"
    t.string "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "credit_applied", precision: 15, scale: 3
    t.integer "client_id"
    t.integer "company_id"
    t.string "status"
    t.string "provider"
    t.string "provider_id"
    t.integer "currency_id"
    t.integer "created_by"
    t.integer "updated_by"
  end

  create_table "permissions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.boolean "can_create"
    t.boolean "can_update"
    t.boolean "can_delete"
    t.boolean "can_read"
    t.string "entity_type"
    t.bigint "role_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["role_id"], name: "index_permissions_on_role_id"
  end

  create_table "project_tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.float "rate"
    t.string "archive_number"
    t.datetime "archived_at"
    t.integer "project_id"
    t.integer "task_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "start_date"
    t.datetime "due_date"
    t.float "hours"
    t.float "spent_time"
  end

  create_table "projects", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "project_name"
    t.integer "client_id"
    t.integer "manager_id"
    t.string "billing_method"
    t.text "description"
    t.integer "total_hours"
    t.integer "company_id"
    t.integer "updated_by"
    t.integer "created_by"
    t.string "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "provider_id"
  end

  create_table "recurring_frequencies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "number_of_days"
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "recurring_profile_line_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "recurring_profile_id"
    t.integer "item_id"
    t.string "item_name"
    t.string "item_description"
    t.decimal "item_unit_cost", precision: 10, scale: 2
    t.decimal "item_quantity", precision: 10, scale: 2
    t.integer "tax_1"
    t.integer "tax_2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
  end

  create_table "recurring_profiles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "first_invoice_date"
    t.string "po_number"
    t.decimal "discount_percentage", precision: 10, scale: 2
    t.string "frequency"
    t.integer "occurrences"
    t.boolean "prorate"
    t.decimal "prorate_for", precision: 10, scale: 2
    t.integer "gateway_id"
    t.integer "client_id"
    t.text "notes"
    t.string "status"
    t.decimal "sub_total", precision: 10, scale: 2
    t.decimal "discount_amount", precision: 10, scale: 2
    t.decimal "tax_amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invoice_number"
    t.string "discount_type"
    t.decimal "invoice_total", precision: 10, scale: 2
    t.string "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.integer "payment_terms_id"
    t.integer "company_id"
    t.string "last_invoice_status"
    t.datetime "last_sent_date"
    t.integer "sent_invoices"
    t.integer "currency_id"
    t.integer "created_by"
    t.integer "updated_by"
  end

  create_table "recurring_schedules", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "next_invoice_date"
    t.string "frequency"
    t.integer "occurrences", default: 0
    t.string "delivery_option"
    t.integer "invoice_id"
    t.integer "generated_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "enable_recurring", default: true
    t.integer "frequency_repetition"
    t.string "frequency_type"
  end

  create_table "roles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "for_client", default: false
    t.boolean "deletable", default: true
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "sent_emails", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.date "date"
    t.string "sender"
    t.string "recipient"
    t.string "type"
    t.string "subject"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notification_id"
    t.string "notification_type"
    t.integer "company_id"
  end

  create_table "sessions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "settings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "staffs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.float "rate"
    t.integer "created_by"
    t.integer "updated_by"
    t.string "archive_number"
    t.datetime "archived_at"
    t.time "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "company_id"
    t.string "provider"
    t.string "provider_id"
    t.integer "user_id"
  end

  create_table "tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "billable"
    t.float "rate"
    t.string "archive_number"
    t.datetime "archived_at"
    t.time "deleted_at"
    t.integer "updated_by"
    t.integer "created_by"
    t.integer "project_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "provider_id"
  end

  create_table "taxes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.decimal "percentage", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "archive_number"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.string "provider"
    t.string "provider_id"
  end

  create_table "team_members", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.float "rate"
    t.string "archive_number"
    t.datetime "archived_at"
    t.integer "project_id"
    t.integer "staff_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_salt"
    t.string "user_name"
    t.integer "current_company"
    t.string "authentication_token"
    t.string "avatar"
    t.bigint "role_id"
    t.boolean "have_all_companies_access", default: false
    t.index ["authentication_token"], name: "index_users_on_authentication_token"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  create_table "versions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "clients", "roles"
  add_foreign_key "introductions", "clients"
  add_foreign_key "introductions", "users"
  add_foreign_key "mail_configs", "companies"
  add_foreign_key "permissions", "roles"
  add_foreign_key "users", "roles"
end
