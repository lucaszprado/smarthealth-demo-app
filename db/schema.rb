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

ActiveRecord::Schema[7.1].define(version: 2024_09_19_195733) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.string "optimal_min_value"
    t.string "float"
    t.float "optimal_max_value"
    t.bigint "biomarker_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "humans", force: :cascade do |t|
    t.string "name"
    t.string "gender"
    t.date "birthdate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "measures", force: :cascade do |t|
    t.float "value"
    t.float "original_value"
    t.datetime "date"
    t.bigint "biomarker_id", null: false
    t.bigint "category_id", null: false
    t.bigint "unit_id", null: false
    t.bigint "human_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["biomarker_id"], name: "index_measures_on_biomarker_id"
    t.index ["category_id"], name: "index_measures_on_category_id"
    t.index ["human_id"], name: "index_measures_on_human_id"
    t.index ["unit_id"], name: "index_measures_on_unit_id"
  end

  create_table "synonyms", force: :cascade do |t|
    t.string "name"
    t.bigint "biomarker_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "language"
    t.index ["biomarker_id"], name: "index_synonyms_on_biomarker_id"
  end

  create_table "units", force: :cascade do |t|
    t.string "name"
    t.string "synomys_string"
    t.integer "value_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "external_ref"
  end

  add_foreign_key "biomarkers_ranges", "biomarkers"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "measures", "biomarkers"
  add_foreign_key "measures", "categories"
  add_foreign_key "measures", "humans"
  add_foreign_key "measures", "units"
  add_foreign_key "synonyms", "biomarkers"
end
