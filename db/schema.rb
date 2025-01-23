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

ActiveRecord::Schema[7.1].define(version: 2025_01_17_103150) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "biomarkers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "external_ref"
  end

  create_table "biomarkers_ranges", force: :cascade do |t|
    t.string "gender"
    t.integer "age"
    t.float "possible_min_value"
    t.float "possible_max_value"
    t.float "optimal_max_value"
    t.bigint "biomarker_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "optimal_min_value"
    t.index ["biomarker_id"], name: "index_biomarkers_ranges_on_biomarker_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "external_ref"
    t.bigint "parent_id"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "health_professionals", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "health_providers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "humans", force: :cascade do |t|
    t.string "name"
    t.string "gender"
    t.date "birthdate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "imaging_methods", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "imaging_reports", force: :cascade do |t|
    t.string "content"
    t.bigint "source_id", null: false
    t.bigint "imaging_method_id", null: false
    t.bigint "report_summary_id", null: false
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["imaging_method_id"], name: "index_imaging_reports_on_imaging_method_id"
    t.index ["report_summary_id"], name: "index_imaging_reports_on_report_summary_id"
    t.index ["source_id"], name: "index_imaging_reports_on_source_id"
  end

  create_table "label_assignments", force: :cascade do |t|
    t.bigint "label_id", null: false
    t.string "labelable_type", null: false
    t.bigint "labelable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["label_id"], name: "index_label_assignments_on_label_id"
    t.index ["labelable_type", "labelable_id"], name: "index_label_assignments_on_labelable"
  end

  create_table "label_relationships", force: :cascade do |t|
    t.bigint "parent_label_id", null: false
    t.bigint "child_label_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_label_id"], name: "index_label_relationships_on_child_label_id"
    t.index ["parent_label_id"], name: "index_label_relationships_on_parent_label_id"
  end

  create_table "labels", force: :cascade do |t|
    t.string "name"
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_labels_on_category_id"
  end

  create_table "measures", force: :cascade do |t|
    t.float "value"
    t.float "original_value"
    t.datetime "date"
    t.bigint "biomarker_id"
    t.bigint "category_id"
    t.bigint "unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "source_id"
    t.index ["biomarker_id"], name: "index_measures_on_biomarker_id"
    t.index ["category_id"], name: "index_measures_on_category_id"
    t.index ["source_id"], name: "index_measures_on_source_id"
    t.index ["unit_id"], name: "index_measures_on_unit_id"
  end

  create_table "report_summaries", force: :cascade do |t|
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "source_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sources", force: :cascade do |t|
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "human_id", null: false
    t.bigint "source_type_id"
    t.bigint "health_professional_id"
    t.bigint "health_provider_id"
    t.index ["health_professional_id"], name: "index_sources_on_health_professional_id"
    t.index ["health_provider_id"], name: "index_sources_on_health_provider_id"
    t.index ["human_id"], name: "index_sources_on_human_id"
    t.index ["source_type_id"], name: "index_sources_on_source_type_id"
  end

  create_table "synonyms", force: :cascade do |t|
    t.string "name"
    t.bigint "biomarker_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "language"
    t.index ["biomarker_id"], name: "index_synonyms_on_biomarker_id"
  end

  create_table "unit_factors", force: :cascade do |t|
    t.float "factor"
    t.bigint "biomarker_id", null: false
    t.bigint "unit_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["biomarker_id"], name: "index_unit_factors_on_biomarker_id"
    t.index ["unit_id"], name: "index_unit_factors_on_unit_id"
  end

  create_table "units", force: :cascade do |t|
    t.string "name"
    t.string "synomys_string"
    t.integer "value_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "external_ref"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "biomarkers_ranges", "biomarkers"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "imaging_reports", "imaging_methods"
  add_foreign_key "imaging_reports", "report_summaries"
  add_foreign_key "imaging_reports", "sources"
  add_foreign_key "label_assignments", "labels"
  add_foreign_key "label_relationships", "labels", column: "child_label_id"
  add_foreign_key "label_relationships", "labels", column: "parent_label_id"
  add_foreign_key "labels", "categories"
  add_foreign_key "measures", "biomarkers"
  add_foreign_key "measures", "categories"
  add_foreign_key "measures", "sources"
  add_foreign_key "measures", "units"
  add_foreign_key "sources", "health_professionals"
  add_foreign_key "sources", "health_providers"
  add_foreign_key "sources", "humans"
  add_foreign_key "sources", "source_types"
  add_foreign_key "synonyms", "biomarkers"
  add_foreign_key "unit_factors", "biomarkers"
  add_foreign_key "unit_factors", "units"
end
