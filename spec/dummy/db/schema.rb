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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121019040009) do

  create_table "accounts", :primary_key => "account_id", :force => true do |t|
    t.text "account", :null => false
  end

  add_index "accounts", ["account"], :name => "index_accounts_on_account", :unique => true

  create_table "addresses", :primary_key => "address_id", :force => true do |t|
    t.integer "city_id"
    t.integer "state_id"
    t.integer "postal_code_id"
    t.integer "street_id"
  end

  create_table "cities", :primary_key => "city_id", :force => true do |t|
    t.text "city", :null => false
  end

  add_index "cities", ["city"], :name => "index_cities_on_city", :unique => true

  create_table "email_addresses", :primary_key => "email_address_id", :force => true do |t|
    t.text "email_address", :null => false
  end

  add_index "email_addresses", ["email_address"], :name => "index_email_addresses_on_email_address", :unique => true

  create_table "ip_addresses", :primary_key => "ip_address_id", :force => true do |t|
    t.text "ip_address", :null => false
  end

  add_index "ip_addresses", ["ip_address"], :name => "index_ip_addresses_on_ip_address", :unique => true

  create_table "postal_codes", :primary_key => "postal_code_id", :force => true do |t|
    t.text "postal_code", :null => false
  end

  add_index "postal_codes", ["postal_code"], :name => "index_postal_codes_on_postal_code", :unique => true

  create_table "states", :primary_key => "state_id", :force => true do |t|
    t.text "state", :null => false
  end

  add_index "states", ["state"], :name => "index_states_on_state", :unique => true

  create_table "statuses", :primary_key => "status_id", :force => true do |t|
    t.text "status", :null => false
  end

  add_index "statuses", ["status"], :name => "index_statuses_on_status", :unique => true

  create_table "streets", :primary_key => "street_id", :force => true do |t|
    t.text "street", :null => false
  end

  add_index "streets", ["street"], :name => "index_streets_on_street", :unique => true

end
