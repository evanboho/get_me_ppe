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

ActiveRecord::Schema.define(version: 2020_04_08_195833) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "donors", force: :cascade do |t|
    t.string "name"
    t.string "email_address"
    t.string "phone_number"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "address_street"
    t.string "address_apartment"
    t.string "address_city"
    t.string "address_zip"
    t.string "status"
    t.integer "number_of_masks"
    t.string "mask_condition"
    t.string "region"
    t.string "contact_method"
    t.string "onfleet_task_id"
    t.string "other_ppe"
    t.string "donor_comments"
    t.integer "mask_count"
    t.integer "gloves_count"
    t.integer "other_ppe_count"
    t.string "timestamp"
    t.index ["onfleet_task_id"], name: "index_donors_on_onfleet_task_id"
  end

  create_table "hospitals", force: :cascade do |t|
    t.string "organization"
    t.string "address"
    t.string "contact_name"
    t.string "contact_email"
    t.string "contact_phone"
    t.boolean "respirators"
    t.boolean "gowns"
    t.boolean "goggles"
    t.boolean "gloves"
    t.boolean "sanitzer"
    t.boolean "sample_collection_products"
    t.boolean "hand_sewn_masks"
    t.boolean "accepts_opened_ppe"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "address_street"
    t.string "address_apartment"
    t.string "address_city"
    t.string "address_zip"
    t.string "address_state"
    t.string "notes"
  end

  create_table "onfleet_webhook_requests", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "zendesk_sync_error"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
