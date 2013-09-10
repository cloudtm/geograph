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

ActiveRecord::Schema.define(:version => 20130610111649) do

  create_table "countries", :force => true do |t|
    t.string   "name"
    t.float    "min_latitude"
    t.float    "max_latitude"
    t.float    "min_longitude"
    t.float    "max_longitude"
    t.string   "country"
    t.string   "continent"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "track_count"
  end

  add_index "countries", ["country"], :name => "index_countries_on_country"
  add_index "countries", ["name", "track_count"], :name => "index_countries_on_name_and_track_count"
  add_index "countries", ["name"], :name => "index_countries_on_name"

  create_table "countries_bak", :force => true do |t|
    t.string   "name"
    t.float    "min_latitude"
    t.float    "min_longitude"
    t.float    "max_latitude"
    t.float    "max_longitude"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "country"
  end

  add_index "countries_bak", ["country", "max_latitude"], :name => "max_lat"
  add_index "countries_bak", ["country", "max_longitude"], :name => "max_lon"
  add_index "countries_bak", ["country", "min_latitude"], :name => "min_lat"
  add_index "countries_bak", ["country", "min_longitude"], :name => "min_lon"
  add_index "countries_bak", ["country"], :name => "index_tags_on_country"
  add_index "countries_bak", ["name"], :name => "index_tags_on_name"

  create_table "tab_cities", :id => false, :force => true do |t|
    t.string "country"
    t.string "city"
    t.string "accentcity"
    t.string "region"
    t.string "population"
    t.float  "latitude"
    t.float  "longitude"
  end

  create_table "tab_countries_codes", :id => false, :force => true do |t|
    t.string "code", :limit => 2, :null => false
    t.string "name",              :null => false
  end

  add_index "tab_countries_codes", ["code"], :name => "tab_countries_codes_code1"

  create_table "tab_countries_per_continent", :primary_key => "country", :force => true do |t|
    t.string "continent", :limit => 2, :null => false
  end

  create_table "tab_track_count_per_country", :id => false, :force => true do |t|
    t.string  "country"
    t.integer "count(*)", :limit => 8, :default => 0, :null => false
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.float    "min_latitude"
    t.float    "min_longitude"
    t.float    "max_latitude"
    t.float    "max_longitude"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "country"
    t.integer  "track_count"
  end

  add_index "tags", ["country", "max_latitude"], :name => "max_lat"
  add_index "tags", ["country", "max_longitude"], :name => "max_lon"
  add_index "tags", ["country", "min_latitude"], :name => "min_lat"
  add_index "tags", ["country", "min_longitude"], :name => "min_lon"
  add_index "tags", ["country"], :name => "index_tags_on_country"
  add_index "tags", ["name", "track_count"], :name => "index_tags_on_name_and_track_count"
  add_index "tags", ["name"], :name => "index_tags_on_name"

  create_table "track_count_per_citycountry", :id => false, :force => true do |t|
    t.string  "city"
    t.string  "country"
    t.string  "citycountry"
    t.integer "count(*)",    :limit => 8, :default => 0, :null => false
  end

  add_index "track_count_per_citycountry", ["citycountry"], :name => "citycountry"

  create_table "tracks", :force => true do |t|
    t.string   "title"
    t.string   "filename"
    t.text     "content",                  :limit => 16777215
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.float    "first_position_latitude"
    t.float    "first_position_longitude"
    t.string   "country"
    t.string   "city"
    t.string   "continent"
    t.integer  "city_idx"
    t.integer  "country_idx"
    t.integer  "continent_idx"
    t.string   "citycountry"
    t.integer  "citycountry_idx"
  end

  add_index "tracks", ["city", "city_idx"], :name => "index_tracks_on_city_and_city_idx"
  add_index "tracks", ["city"], :name => "index_tracks_on_city"
  add_index "tracks", ["citycountry", "citycountry_idx"], :name => "index_tracks_on_citycountry_and_citycountry_idx"
  add_index "tracks", ["citycountry"], :name => "index_tracks_on_citycountry"
  add_index "tracks", ["continent", "continent_idx"], :name => "index_tracks_on_continent_and_continent_idx"
  add_index "tracks", ["continent"], :name => "index_tracks_on_continent"
  add_index "tracks", ["country", "country_idx"], :name => "index_tracks_on_country_and_country_idx"
  add_index "tracks", ["country"], :name => "index_tracks_on_country"
  add_index "tracks", ["first_position_latitude", "first_position_longitude"], :name => "first_position_index"
  add_index "tracks", ["first_position_latitude"], :name => "index_tracks_on_first_position_latitude"
  add_index "tracks", ["first_position_longitude"], :name => "index_tracks_on_first_position_longitude"

end
