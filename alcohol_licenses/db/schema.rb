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

ActiveRecord::Schema.define(version: 2026_08_08_161000) do

  create_table "address_corrections", force: :cascade do |t|
    t.integer "location_id", null: false
    t.integer "source_location_id"
    t.string "corrected_address_1", null: false
    t.string "corrected_address_2"
    t.string "source", null: false
    t.string "method", null: false
    t.float "confidence", null: false
    t.boolean "selected", default: false, null: false
    t.text "evidence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id", "selected"], name: "index_address_corrections_on_selected"
    t.index ["location_id", "source", "method", "corrected_address_1", "corrected_address_2"], name: "index_address_corrections_on_identity", unique: true
    t.index ["location_id"], name: "index_address_corrections_on_location_id"
    t.index ["source_location_id"], name: "index_address_corrections_on_source_location_id"
  end

  create_table "alcohol_licenses", force: :cascade do |t|
    t.datetime "expires_at"
    t.datetime "reported_at"
    t.integer "business_category_id"
    t.integer "license_category_id"
    t.integer "location_id"
    t.integer "business_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "license_point_group_id"
    t.index ["business_category_id"], name: "index_alcohol_licenses_on_business_category_id"
    t.index ["business_id"], name: "index_alcohol_licenses_on_business_id"
    t.index ["license_category_id"], name: "index_alcohol_licenses_on_license_category_id"
    t.index ["license_point_group_id"], name: "index_alcohol_licenses_on_license_point_group_id"
    t.index ["location_id"], name: "index_alcohol_licenses_on_location_id"
  end

  create_table "business_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "businesses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "geocoding_results", force: :cascade do |t|
    t.integer "transformed_location_id", null: false
    t.string "source", null: false
    t.string "strategy", null: false
    t.string "query", null: false
    t.float "latitude"
    t.float "longitude"
    t.float "confidence"
    t.string "precision"
    t.boolean "selected", default: false, null: false
    t.text "raw_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transformed_location_id", "selected"], name: "index_geocoding_results_on_selected"
    t.index ["transformed_location_id", "source", "strategy", "query"], name: "index_geocoding_results_on_source_identity", unique: true
    t.index ["transformed_location_id"], name: "index_geocoding_results_on_transformed_location_id"
  end

  create_table "geocoding_reviews", force: :cascade do |t|
    t.integer "transformed_location_id", null: false
    t.string "signal_category", null: false
    t.string "review_status", null: false
    t.string "reviewed_by"
    t.float "original_latitude"
    t.float "original_longitude"
    t.float "manual_latitude"
    t.float "manual_longitude"
    t.integer "selected_geocoding_result_id"
    t.integer "manual_geocoding_result_id"
    t.text "quality_signals"
    t.text "note"
    t.datetime "reviewed_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "sim_circle_within_area"
    t.index ["transformed_location_id", "signal_category", "review_status"], name: "index_geocoding_reviews_on_location_category_status"
    t.index ["transformed_location_id"], name: "index_geocoding_reviews_on_transformed_location_id"
  end

  create_table "license_categories", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "license_point_groups", force: :cascade do |t|
    t.datetime "reported_at", null: false
    t.float "latitude", null: false
    t.float "longitude", null: false
    t.string "normalized_business_name", null: false
    t.string "display_business_name", null: false
    t.text "business_names", null: false
    t.text "business_ids", null: false
    t.float "similarity_floor", default: 1.0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reported_at", "latitude", "longitude"], name: "index_license_point_groups_on_report_location"
  end

  create_table "locations", force: :cascade do |t|
    t.string "address_1"
    t.string "address_2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "transformed_location_id"
    t.index ["transformed_location_id"], name: "index_locations_on_transformed_location_id"
  end

  create_table "sim_populations", force: :cascade do |t|
    t.date "observed_on", null: false
    t.integer "observed_on_code", null: false
    t.string "sim_unit_code", null: false
    t.string "sim_unit_name", null: false
    t.string "district_code", null: false
    t.string "district_name", null: false
    t.integer "total", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["district_name"], name: "index_sim_populations_on_district_name"
    t.index ["observed_on", "sim_unit_code"], name: "index_sim_populations_on_observed_on_and_sim_unit_code", unique: true
    t.index ["observed_on"], name: "index_sim_populations_on_observed_on"
  end

  create_table "streets", force: :cascade do |t|
    t.string "trait"
    t.string "name_1"
    t.string "name_2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transformed_locations", force: :cascade do |t|
    t.string "address_1"
    t.string "building_number"
    t.float "latitude"
    t.float "longtitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address_kind"
    t.string "address_relation"
    t.string "unit_number"
    t.string "parcel_number"
    t.string "raw_address_2"
    t.string "parcel_region"
    t.string "parcel_cadastral_unit"
    t.float "osm_latitude"
    t.float "osm_longitude"
    t.string "osm_geocoding_strategy"
    t.string "osm_geocoding_precision"
    t.string "osm_geocoding_query"
    t.text "same_as"
    t.float "krakow_msip_latitude"
    t.float "krakow_msip_longitude"
    t.float "gus_latitude"
    t.float "gus_longitude"
    t.float "nominatim_latitude"
    t.float "nominatim_longitude"
    t.float "google_latitude"
    t.float "google_longitude"
    t.float "uldk_latitude"
    t.float "uldk_longitude"
    t.integer "selected_geocoding_result_id"
    t.string "selected_geocoding_source"
    t.string "selected_geocoding_strategy"
    t.string "selected_geocoding_precision"
    t.string "selected_geocoding_query"
    t.index ["address_1", "building_number", "address_kind", "address_relation", "unit_number", "parcel_number", "parcel_region", "parcel_cadastral_unit"], name: "index_transformed_locations_on_geocoding_identity", unique: true
  end

  add_foreign_key "address_corrections", "locations"
  add_foreign_key "address_corrections", "locations", column: "source_location_id"
  add_foreign_key "alcohol_licenses", "business_categories"
  add_foreign_key "alcohol_licenses", "businesses"
  add_foreign_key "alcohol_licenses", "license_categories"
  add_foreign_key "alcohol_licenses", "license_point_groups"
  add_foreign_key "alcohol_licenses", "locations"
  add_foreign_key "geocoding_results", "transformed_locations"
  add_foreign_key "geocoding_reviews", "transformed_locations"
  add_foreign_key "locations", "transformed_locations"
end
