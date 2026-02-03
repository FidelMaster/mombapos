# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_02_02_160839) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_receivable_details", force: :cascade do |t|
    t.bigint "document_account_receivable_id", null: false
    t.string "document_type"
    t.integer "document_id"
    t.string "document_number"
    t.decimal "amount"
    t.decimal "amount_in_usd"
    t.decimal "exchange_rate"
    t.string "movement_type"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_account_receivable_id"], name: "idx_on_document_account_receivable_id_0d8ea6e663"
  end

  create_table "app_modules", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_modules_menu_items", force: :cascade do |t|
    t.bigint "app_module_id", null: false
    t.bigint "menu_item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_module_id", "menu_item_id"], name: "index_modules_menu_unique", unique: true
    t.index ["app_module_id"], name: "index_app_modules_menu_items_on_app_module_id"
    t.index ["menu_item_id"], name: "index_app_modules_menu_items_on_menu_item_id"
  end

  create_table "areas", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active", default: true
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id", null: false
    t.index ["tenant_id"], name: "index_areas_on_tenant_id"
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.bigint "bank_id", null: false
    t.string "account_number"
    t.string "account_name"
    t.string "currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id"
    t.index ["bank_id"], name: "index_bank_accounts_on_bank_id"
    t.index ["tenant_id"], name: "index_bank_accounts_on_tenant_id"
  end

  create_table "banks", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_banks_on_tenant_id"
  end

  create_table "branches", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name"
    t.boolean "is_default"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_branches_on_tenant_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customer_addresses", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "address"
    t.bigint "department_id", null: false
    t.bigint "municipality_id", null: false
    t.boolean "is_default"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: "Direccion 1"
    t.index ["customer_id"], name: "index_customer_addresses_on_customer_id"
    t.index ["department_id"], name: "index_customer_addresses_on_department_id"
    t.index ["municipality_id"], name: "index_customer_addresses_on_municipality_id"
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name"
    t.string "tax_id"
    t.string "address"
    t.bigint "municipality_id", null: false
    t.string "contact_name"
    t.string "contact_email"
    t.string "contact_phone"
    t.decimal "credit_limit"
    t.boolean "is_tax_exempt"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "department_id"
    t.index ["department_id"], name: "index_customers_on_department_id"
    t.index ["municipality_id"], name: "index_customers_on_municipality_id"
    t.index ["tenant_id"], name: "index_customers_on_tenant_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "country_id"
  end

  create_table "dining_tables", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "code"
    t.integer "capacity"
    t.string "status", default: "free", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "area_id"
    t.index ["area_id"], name: "index_dining_tables_on_area_id"
    t.index ["tenant_id"], name: "index_dining_tables_on_tenant_id"
  end

  create_table "document_account_receivables", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "payment_term_id", null: false
    t.bigint "customer_id", null: false
    t.integer "document_id", null: false
    t.string "document_number", default: ""
    t.string "document_reference_number", default: ""
    t.string "document_type", default: ""
    t.text "description", default: ""
    t.decimal "amount", default: "0.0"
    t.decimal "amount_in_usd", default: "0.0"
    t.decimal "balance", default: "0.0"
    t.decimal "balance_in_usd", default: "0.0"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "exchange_rate"
    t.index ["customer_id"], name: "index_document_account_receivables_on_customer_id"
    t.index ["payment_term_id"], name: "index_document_account_receivables_on_payment_term_id"
    t.index ["tenant_id"], name: "index_document_account_receivables_on_tenant_id"
  end

  create_table "exchange_rates", force: :cascade do |t|
    t.string "currency"
    t.decimal "rate"
    t.date "effective_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id"
    t.index ["tenant_id"], name: "index_exchange_rates_on_tenant_id"
  end

  create_table "group_members", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "student_id", null: false
    t.decimal "score"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_members_on_group_id"
    t.index ["student_id"], name: "index_group_members_on_student_id"
  end

  create_table "group_tasks", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.string "name"
    t.text "description"
    t.text "observation"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_tasks_on_group_id"
  end

  create_table "groups", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "trainer_id", null: false
    t.string "name"
    t.text "description"
    t.date "execution_date"
    t.date "end_date"
    t.time "execution_hour"
    t.string "status"
    t.integer "max_students"
    t.integer "duration_in_minutes"
    t.decimal "price"
    t.decimal "total_incomes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_groups_on_tenant_id"
    t.index ["trainer_id"], name: "index_groups_on_trainer_id"
  end

  create_table "invoice_items", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.bigint "product_id", null: false
    t.bigint "unit_measure_id", null: false
    t.decimal "quantity"
    t.decimal "unit_price"
    t.decimal "subtotal"
    t.decimal "tax_amount"
    t.decimal "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_items_on_invoice_id"
    t.index ["product_id"], name: "index_invoice_items_on_product_id"
    t.index ["unit_measure_id"], name: "index_invoice_items_on_unit_measure_id"
  end

  create_table "invoice_payments", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.bigint "payment_method_id", null: false
    t.bigint "bank_account_id"
    t.string "currency"
    t.decimal "exchange_rate"
    t.decimal "amount"
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_account_id"], name: "index_invoice_payments_on_bank_account_id"
    t.index ["invoice_id"], name: "index_invoice_payments_on_invoice_id"
    t.index ["payment_method_id"], name: "index_invoice_payments_on_payment_method_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "customer_id", null: false
    t.string "invoice_number"
    t.date "invoice_date"
    t.bigint "branch_id", null: false
    t.bigint "warehouse_id", null: false
    t.string "customer_name_snapshot"
    t.string "customer_tax_id_snapshot"
    t.string "invoice_type"
    t.string "status"
    t.decimal "exchange_rate"
    t.decimal "total_items"
    t.decimal "subtotal_amount"
    t.decimal "tax_amount"
    t.decimal "total_local_amount"
    t.decimal "total_foreign_amount"
    t.bigint "issued_by"
    t.bigint "annulled_by"
    t.datetime "annulled_at"
    t.string "annulment_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "order_id"
    t.bigint "price_list_id"
    t.text "notes"
    t.bigint "payment_term_id"
    t.date "issue_date"
    t.date "due_date"
    t.index ["branch_id"], name: "index_invoices_on_branch_id"
    t.index ["customer_id"], name: "index_invoices_on_customer_id"
    t.index ["order_id"], name: "index_invoices_on_order_id"
    t.index ["payment_term_id"], name: "index_invoices_on_payment_term_id"
    t.index ["price_list_id"], name: "index_invoices_on_price_list_id"
    t.index ["tenant_id"], name: "index_invoices_on_tenant_id"
    t.index ["warehouse_id"], name: "index_invoices_on_warehouse_id"
  end

  create_table "levels", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name"
    t.integer "order"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_levels_on_tenant_id"
  end

  create_table "license_modules", force: :cascade do |t|
    t.bigint "license_id", null: false
    t.bigint "app_module_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_module_id"], name: "index_license_modules_on_app_module_id"
    t.index ["license_id"], name: "index_license_modules_on_license_id"
  end

  create_table "licenses", force: :cascade do |t|
    t.string "name"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "menu_items", force: :cascade do |t|
    t.string "key", null: false
    t.string "label", null: false
    t.string "icon"
    t.string "path"
    t.string "section"
    t.integer "position"
    t.string "item_type", null: false
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_type"], name: "index_menu_items_on_item_type"
    t.index ["key"], name: "index_menu_items_on_key", unique: true
    t.index ["parent_id"], name: "index_menu_items_on_parent_id"
  end

  create_table "municipalities", force: :cascade do |t|
    t.bigint "department_id", null: false
    t.string "name"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_municipalities_on_department_id"
  end

  create_table "objectives", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_objectives_on_tenant_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.decimal "quantity", precision: 10, scale: 2, default: "1.0", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.decimal "subtotal", precision: 12, scale: 2, null: false
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "order_code"
    t.bigint "dining_table_id"
    t.bigint "customer_id", null: false
    t.string "customer_name"
    t.string "status", default: "open", null: false
    t.integer "total_items", default: 0, null: false
    t.decimal "total", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order_type", default: 0
    t.text "delivery_address"
    t.string "customer_phone"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["dining_table_id"], name: "index_orders_on_dining_table_id"
    t.index ["tenant_id"], name: "index_orders_on_tenant_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_terms", force: :cascade do |t|
    t.string "name"
    t.decimal "total", default: "0.0"
    t.text "description"
    t.boolean "is_active", default: true
    t.decimal "grace_days", default: "0.0"
    t.decimal "early_payment_discount", default: "0.0"
    t.decimal "late_fee_percentage", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plan_detail_objectives", force: :cascade do |t|
    t.bigint "plan_detail_id", null: false
    t.text "description"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_detail_id"], name: "index_plan_detail_objectives_on_plan_detail_id"
  end

  create_table "plan_detail_structure_tasks", force: :cascade do |t|
    t.bigint "plan_detail_structure_id", null: false
    t.string "turn"
    t.text "description"
    t.integer "percentage"
    t.boolean "is_complete"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_detail_structure_id"], name: "index_plan_detail_structure_tasks_on_plan_detail_structure_id"
  end

  create_table "plan_detail_structures", force: :cascade do |t|
    t.bigint "plan_detail_id", null: false
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_detail_id"], name: "index_plan_detail_structures_on_plan_detail_id"
  end

  create_table "plan_details", force: :cascade do |t|
    t.bigint "plan_id", null: false
    t.string "name"
    t.integer "duration_in_days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_id"], name: "index_plan_details_on_plan_id"
  end

  create_table "plan_extra_control_details", force: :cascade do |t|
    t.bigint "plan_extra_control_id", null: false
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_extra_control_id"], name: "index_plan_extra_control_details_on_plan_extra_control_id"
  end

  create_table "plan_extra_controls", force: :cascade do |t|
    t.bigint "plan_id", null: false
    t.string "control_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_id"], name: "index_plan_extra_controls_on_plan_id"
  end

  create_table "plans", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "trainer_id", null: false
    t.bigint "student_id", null: false
    t.string "name"
    t.text "description"
    t.text "observation"
    t.boolean "is_active"
    t.integer "total_duration_in_days"
    t.string "tournament"
    t.string "event"
    t.date "event_date"
    t.text "event_observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_plans_on_student_id"
    t.index ["tenant_id"], name: "index_plans_on_tenant_id"
    t.index ["trainer_id"], name: "index_plans_on_trainer_id"
  end

  create_table "price_list_items", force: :cascade do |t|
    t.bigint "price_list_id", null: false
    t.bigint "product_id", null: false
    t.decimal "price"
    t.boolean "includes_tax"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["price_list_id"], name: "index_price_list_items_on_price_list_id"
    t.index ["product_id"], name: "index_price_list_items_on_product_id"
  end

  create_table "price_lists", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name"
    t.string "currency"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_price_lists_on_tenant_id"
  end

  create_table "product_categories", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_product_categories_on_tenant_id"
  end

  create_table "product_composition_items", force: :cascade do |t|
    t.bigint "product_composition_id", null: false
    t.bigint "product_id", null: false
    t.decimal "quantity"
    t.bigint "unit_measure_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_composition_id"], name: "index_product_composition_items_on_product_composition_id"
    t.index ["product_id"], name: "index_product_composition_items_on_product_id"
    t.index ["unit_measure_id"], name: "index_product_composition_items_on_unit_measure_id"
  end

  create_table "product_compositions", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "product_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_compositions_on_product_id"
    t.index ["tenant_id"], name: "index_product_compositions_on_tenant_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "product_code"
    t.string "name"
    t.text "description"
    t.string "product_type"
    t.bigint "product_category_id", null: false
    t.decimal "cost"
    t.bigint "stock_unit_measure_id", null: false
    t.bigint "sale_unit_measure_id", null: false
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "supplier_id"
    t.decimal "price"
    t.decimal "quantity"
    t.boolean "stockeable", default: false
    t.index ["product_category_id"], name: "index_products_on_product_category_id"
    t.index ["sale_unit_measure_id"], name: "index_products_on_sale_unit_measure_id"
    t.index ["stock_unit_measure_id"], name: "index_products_on_stock_unit_measure_id"
    t.index ["supplier_id"], name: "index_products_on_supplier_id"
    t.index ["tenant_id"], name: "index_products_on_tenant_id"
  end

  create_table "receipts", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.date "receipt_date"
    t.decimal "total_amount", default: "0.0"
    t.string "payment_method"
    t.string "reference"
    t.bigint "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "document_account_receivable_id", null: false
    t.index ["customer_id"], name: "index_receipts_on_customer_id"
    t.index ["document_account_receivable_id"], name: "index_receipts_on_document_account_receivable_id"
    t.index ["tenant_id"], name: "index_receipts_on_tenant_id"
  end

  create_table "resources", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "level_id", null: false
    t.string "name"
    t.string "resource_type"
    t.string "location_url"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["level_id"], name: "index_resources_on_level_id"
    t.index ["tenant_id"], name: "index_resources_on_tenant_id"
  end

  create_table "specialities", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_specialities_on_tenant_id"
  end

  create_table "stock_movements", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "branch_id", null: false
    t.bigint "warehouse_id", null: false
    t.bigint "product_id", null: false
    t.decimal "quantity"
    t.decimal "quantity_before"
    t.string "movement_type"
    t.string "reference_type"
    t.bigint "reference_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_stock_movements_on_branch_id"
    t.index ["product_id"], name: "index_stock_movements_on_product_id"
    t.index ["tenant_id"], name: "index_stock_movements_on_tenant_id"
    t.index ["warehouse_id"], name: "index_stock_movements_on_warehouse_id"
  end

  create_table "stock_unit_measures", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_stock_unit_measures_on_tenant_id"
  end

  create_table "student_games", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "student_id", null: false
    t.string "opponent_fide_code"
    t.string "opponent_name"
    t.integer "opponent_elo"
    t.decimal "student_average_score"
    t.string "result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_student_games_on_student_id"
    t.index ["tenant_id"], name: "index_student_games_on_tenant_id"
  end

  create_table "students", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "level_id", null: false
    t.bigint "department_id", null: false
    t.bigint "municipality_id", null: false
    t.string "name"
    t.string "address"
    t.string "contact_dni"
    t.string "contact_name"
    t.string "contact_email"
    t.string "contact_phone"
    t.date "date_of_birth"
    t.string "code"
    t.decimal "official_average_score"
    t.decimal "online_average_score"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "country_id", null: false
    t.index ["country_id"], name: "index_students_on_country_id"
    t.index ["department_id"], name: "index_students_on_department_id"
    t.index ["level_id"], name: "index_students_on_level_id"
    t.index ["municipality_id"], name: "index_students_on_municipality_id"
    t.index ["tenant_id"], name: "index_students_on_tenant_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name"
    t.string "contact_name"
    t.string "contact_email"
    t.string "contact_phone"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_suppliers_on_tenant_id"
  end

  create_table "taxes", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name"
    t.decimal "rate_percentage"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_taxes_on_tenant_id"
  end

  create_table "tenant_modules", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "app_module_id", null: false
    t.boolean "enabled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_module_id"], name: "index_tenant_modules_on_app_module_id"
    t.index ["tenant_id"], name: "index_tenant_modules_on_tenant_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "uuid"
    t.string "name"
    t.string "subdomain"
    t.string "logo_url"
    t.integer "max_users"
    t.integer "max_invoices"
    t.integer "max_branches"
    t.integer "max_products"
    t.string "default_currency"
    t.string "timezone"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "license_id"
    t.string "email"
    t.index ["license_id"], name: "index_tenants_on_license_id"
  end

  create_table "trainer_specialities", force: :cascade do |t|
    t.bigint "trainer_id", null: false
    t.bigint "speciality_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["speciality_id"], name: "index_trainer_specialities_on_speciality_id"
    t.index ["trainer_id"], name: "index_trainer_specialities_on_trainer_id"
  end

  create_table "trainers", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "user_id", null: false
    t.string "name"
    t.string "email"
    t.string "phone"
    t.decimal "rate_per_hour"
    t.date "hire_date"
    t.bigint "department_id", null: false
    t.bigint "municipality_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_trainers_on_department_id"
    t.index ["municipality_id"], name: "index_trainers_on_municipality_id"
    t.index ["tenant_id"], name: "index_trainers_on_tenant_id"
    t.index ["user_id"], name: "index_trainers_on_user_id"
  end

  create_table "unit_measures", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name"
    t.string "abbreviation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_unit_measures_on_tenant_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id", null: false
    t.integer "role", default: 0, null: false
    t.boolean "is_active", default: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  create_table "warehouse_stocks", force: :cascade do |t|
    t.bigint "warehouse_id", null: false
    t.bigint "product_id", null: false
    t.decimal "stock_available"
    t.decimal "stock_reserved"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "min_quantity"
    t.index ["product_id"], name: "index_warehouse_stocks_on_product_id"
    t.index ["warehouse_id"], name: "index_warehouse_stocks_on_warehouse_id"
  end

  create_table "warehouses", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name"
    t.boolean "is_default"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_warehouses_on_tenant_id"
  end

  add_foreign_key "account_receivable_details", "document_account_receivables"
  add_foreign_key "app_modules_menu_items", "app_modules"
  add_foreign_key "app_modules_menu_items", "menu_items"
  add_foreign_key "areas", "tenants"
  add_foreign_key "bank_accounts", "banks"
  add_foreign_key "bank_accounts", "tenants"
  add_foreign_key "banks", "tenants"
  add_foreign_key "branches", "tenants"
  add_foreign_key "customer_addresses", "customers"
  add_foreign_key "customer_addresses", "departments"
  add_foreign_key "customer_addresses", "municipalities"
  add_foreign_key "customers", "departments"
  add_foreign_key "customers", "municipalities"
  add_foreign_key "customers", "tenants"
  add_foreign_key "departments", "countries"
  add_foreign_key "dining_tables", "areas"
  add_foreign_key "dining_tables", "tenants"
  add_foreign_key "document_account_receivables", "customers"
  add_foreign_key "document_account_receivables", "payment_terms"
  add_foreign_key "document_account_receivables", "tenants"
  add_foreign_key "exchange_rates", "tenants"
  add_foreign_key "group_members", "groups"
  add_foreign_key "group_members", "students"
  add_foreign_key "group_tasks", "groups"
  add_foreign_key "groups", "tenants"
  add_foreign_key "groups", "trainers"
  add_foreign_key "invoice_items", "invoices"
  add_foreign_key "invoice_items", "products"
  add_foreign_key "invoice_items", "unit_measures"
  add_foreign_key "invoice_payments", "bank_accounts"
  add_foreign_key "invoice_payments", "invoices"
  add_foreign_key "invoice_payments", "payment_methods"
  add_foreign_key "invoices", "branches"
  add_foreign_key "invoices", "customers"
  add_foreign_key "invoices", "orders"
  add_foreign_key "invoices", "payment_terms"
  add_foreign_key "invoices", "price_lists"
  add_foreign_key "invoices", "tenants"
  add_foreign_key "invoices", "warehouses"
  add_foreign_key "levels", "tenants"
  add_foreign_key "license_modules", "app_modules"
  add_foreign_key "license_modules", "licenses"
  add_foreign_key "menu_items", "menu_items", column: "parent_id"
  add_foreign_key "municipalities", "departments"
  add_foreign_key "objectives", "tenants"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "dining_tables"
  add_foreign_key "orders", "tenants"
  add_foreign_key "plan_detail_objectives", "plan_details"
  add_foreign_key "plan_detail_structure_tasks", "plan_detail_structures"
  add_foreign_key "plan_detail_structures", "plan_details"
  add_foreign_key "plan_details", "plans"
  add_foreign_key "plan_extra_control_details", "plan_extra_controls"
  add_foreign_key "plan_extra_controls", "plans"
  add_foreign_key "plans", "students"
  add_foreign_key "plans", "tenants"
  add_foreign_key "plans", "trainers"
  add_foreign_key "price_list_items", "price_lists"
  add_foreign_key "price_list_items", "products"
  add_foreign_key "price_lists", "tenants"
  add_foreign_key "product_categories", "tenants"
  add_foreign_key "product_composition_items", "product_compositions"
  add_foreign_key "product_composition_items", "products"
  add_foreign_key "product_composition_items", "unit_measures"
  add_foreign_key "product_compositions", "products"
  add_foreign_key "product_compositions", "tenants"
  add_foreign_key "products", "product_categories"
  add_foreign_key "products", "suppliers"
  add_foreign_key "products", "tenants"
  add_foreign_key "products", "unit_measures", column: "sale_unit_measure_id"
  add_foreign_key "products", "unit_measures", column: "stock_unit_measure_id"
  add_foreign_key "receipts", "customers"
  add_foreign_key "receipts", "document_account_receivables"
  add_foreign_key "receipts", "tenants"
  add_foreign_key "resources", "levels"
  add_foreign_key "resources", "tenants"
  add_foreign_key "specialities", "tenants"
  add_foreign_key "stock_movements", "branches"
  add_foreign_key "stock_movements", "products"
  add_foreign_key "stock_movements", "tenants"
  add_foreign_key "stock_movements", "warehouses"
  add_foreign_key "stock_unit_measures", "tenants"
  add_foreign_key "student_games", "students"
  add_foreign_key "student_games", "tenants"
  add_foreign_key "students", "countries"
  add_foreign_key "students", "departments"
  add_foreign_key "students", "levels"
  add_foreign_key "students", "municipalities"
  add_foreign_key "students", "tenants"
  add_foreign_key "suppliers", "tenants"
  add_foreign_key "taxes", "tenants"
  add_foreign_key "tenant_modules", "app_modules"
  add_foreign_key "tenant_modules", "tenants"
  add_foreign_key "tenants", "licenses"
  add_foreign_key "trainer_specialities", "specialities"
  add_foreign_key "trainer_specialities", "trainers"
  add_foreign_key "trainers", "departments"
  add_foreign_key "trainers", "municipalities"
  add_foreign_key "trainers", "tenants"
  add_foreign_key "trainers", "users"
  add_foreign_key "unit_measures", "tenants"
  add_foreign_key "users", "tenants"
  add_foreign_key "warehouse_stocks", "products"
  add_foreign_key "warehouse_stocks", "warehouses"
  add_foreign_key "warehouses", "tenants"
end
