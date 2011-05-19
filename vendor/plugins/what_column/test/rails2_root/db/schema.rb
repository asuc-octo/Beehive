***REMOVED*** This file is auto-generated from the current state of the database. Instead of editing this file, 
***REMOVED*** please use the migrations feature of Active Record to incrementally modify your database, and
***REMOVED*** then regenerate this schema definition.
***REMOVED***
***REMOVED*** Note that this schema.rb definition is the authoritative source for your database schema. If you need
***REMOVED*** to create the application database on another system, you should be using db:schema:load, not running
***REMOVED*** all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
***REMOVED*** you'll amass, the slower it'll run and the greater likelihood for issues).
***REMOVED***
***REMOVED*** It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090329180225) do

  create_table "products", :force => true do |t|
    t.float    "price"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.integer  "age"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
