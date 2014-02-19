# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100707072636) do

  create_table "admin_users", :force => true do |t|
    t.string  "login",         :limit => 40, :null => false
    t.string  "password_hash", :limit => 40
    t.string  "salt",          :limit => 40
    t.integer "conference_id"
    t.integer "status"
  end

  add_index "admin_users", ["conference_id"], :name => "index_admin_users_on_conference_id"
  add_index "admin_users", ["login"], :name => "index_admin_users_on_login", :unique => true
  add_index "admin_users", ["password_hash"], :name => "index_admin_users_on_password_hash"

  create_table "assignments", :force => true do |t|
    t.integer "enrollment_id",                :null => false
    t.integer "task_id",                      :null => false
    t.float   "hours"
    t.integer "status",        :default => 1, :null => false
    t.string  "comment"
  end

  add_index "assignments", ["enrollment_id", "task_id"], :name => "index_assignments_on_enrollment_id_and_task_id", :unique => true
  add_index "assignments", ["enrollment_id"], :name => "index_assignments_on_enrollment_id"
  add_index "assignments", ["task_id"], :name => "index_assignments_on_task_id"

  create_table "bids", :force => true do |t|
    t.integer "enrollment_id",                :null => false
    t.integer "task_id",                      :null => false
    t.integer "preference",    :default => 1, :null => false
    t.integer "status",        :default => 1, :null => false
  end

  add_index "bids", ["enrollment_id", "task_id"], :name => "index_bids_on_enrollment_id_and_task_id", :unique => true
  add_index "bids", ["enrollment_id"], :name => "index_bids_on_enrollment_id"
  add_index "bids", ["preference"], :name => "index_bids_on_preference"
  add_index "bids", ["task_id"], :name => "index_bids_on_task_id"

  create_table "comments", :force => true do |t|
    t.integer  "user_id",                                                                   :null => false
    t.integer  "conference_id",                                                             :null => false
    t.integer  "type",                                                                      :null => false
    t.text     "text",                                                                      :null => false
    t.integer  "hours",         :limit => 10, :precision => 10, :scale => 0, :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["conference_id"], :name => "index_comments_on_conference_id"
  add_index "comments", ["created_at"], :name => "index_comments_on_created_at"
  add_index "comments", ["type"], :name => "index_comments_on_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "conferences", :force => true do |t|
    t.string   "name",            :default => "unnamed", :null => false
    t.string   "short_name",      :default => "unnamed", :null => false
    t.integer  "year"
    t.string   "email",                                  :null => false
    t.integer  "volunteers",      :default => 40,        :null => false
    t.integer  "volunteer_hours", :default => 20,        :null => false
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "bid_day"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "maintenance",     :default => false
    t.text     "contract"
  end

  add_index "conferences", ["year", "name"], :name => "index_conferences_on_year_and_name", :unique => true

  create_table "countries", :force => true do |t|
    t.string "code", :limit => 2
    t.string "name"
  end

  add_index "countries", ["name"], :name => "index_countries_on_name"

  create_table "drafts", :force => true do |t|
    t.integer  "conference_id", :null => false
    t.integer  "event"
    t.string   "subject",       :null => false
    t.text     "text",          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "drafts", ["conference_id"], :name => "index_drafts_on_conference_id"
  add_index "drafts", ["event", "conference_id"], :name => "index_drafts_on_event_and_conference_id", :unique => true
  add_index "drafts", ["subject"], :name => "index_drafts_on_subject"

  create_table "emails", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.integer  "last_send_attempt", :default => 0
    t.text     "mail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "enrollments", :force => true do |t|
    t.integer "user_id",                              :null => false
    t.integer "conference_id",                        :null => false
    t.integer "status",                :default => 0, :null => false
    t.integer "lottery"
    t.string  "comment"
    t.boolean "past_conferences_this"
    t.boolean "past_sv_this"
    t.boolean "local_experience"
    t.boolean "visa"
  end

  add_index "enrollments", ["conference_id", "status", "lottery"], :name => "index_enrollments_on_conference_id_and_status_and_lottery"
  add_index "enrollments", ["conference_id", "user_id"], :name => "index_enrollments_on_conference_id_and_user_id", :unique => true
  add_index "enrollments", ["conference_id"], :name => "index_enrollments_on_conference_id"
  add_index "enrollments", ["user_id"], :name => "index_enrollments_on_user_id"

  create_table "lottery_configs", :force => true do |t|
    t.integer  "conference_id",                            :null => false
    t.integer  "local_experience"
    t.integer  "past_conferences_this"
    t.integer  "past_sv_this"
    t.integer  "visa"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "degree",                :default => false
  end

  add_index "lottery_configs", ["conference_id"], :name => "index_lottery_configs_on_conference_id"

  create_table "mails", :force => true do |t|
    t.integer  "conference_id", :null => false
    t.string   "from",          :null => false
    t.text     "to",            :null => false
    t.string   "subject",       :null => false
    t.text     "text",          :null => false
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "custom"
  end

  add_index "mails", ["conference_id"], :name => "index_mails_on_conference_id"
  add_index "mails", ["created_at"], :name => "index_mails_on_created_at"
  add_index "mails", ["subject"], :name => "index_mails_on_subject"

  create_table "news", :force => true do |t|
    t.integer  "conference_id", :null => false
    t.string   "title",         :null => false
    t.text     "text",          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "news", ["conference_id"], :name => "index_news_on_conference_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "tasks", :force => true do |t|
    t.integer  "conference_id",                :null => false
    t.string   "name",                         :null => false
    t.text     "description",                  :null => false
    t.string   "location"
    t.integer  "day",                          :null => false
    t.time     "start_time",                   :null => false
    t.time     "end_time",                     :null => false
    t.integer  "slots",                        :null => false
    t.float    "hours",                        :null => false
    t.integer  "priority",                     :null => false
    t.integer  "invisible",     :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tasks", ["conference_id"], :name => "index_tasks_on_conference_id"
  add_index "tasks", ["start_time", "end_time", "name"], :name => "index_tasks_on_start_time_and_end_time_and_name"

  create_table "tickets", :force => true do |t|
    t.string   "code",       :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tickets", ["user_id"], :name => "index_tickets_on_user_id"

  create_table "tshirt_sizes", :force => true do |t|
    t.string  "name"
    t.integer "order"
  end

  add_index "tshirt_sizes", ["order"], :name => "index_tshirt_sizes_on_order"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_hash",        :limit => 40
    t.string   "salt",                 :limit => 40
    t.string   "gender",               :limit => 1
    t.string   "first_name"
    t.string   "last_name"
    t.text     "address"
    t.string   "phone"
    t.string   "university"
    t.string   "department"
    t.string   "student_number"
    t.string   "spoken_languages"
    t.string   "city"
    t.integer  "tshirt_size_id"
    t.integer  "home_country_id"
    t.integer  "residence_country_id"
    t.string   "recovery_token",       :limit => 40
    t.string   "remember_token",       :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "past_conferences"
    t.integer  "degree"
    t.string   "past_sv"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["home_country_id"], :name => "index_users_on_home_country_id"
  add_index "users", ["last_name", "first_name"], :name => "index_users_on_last_name_and_first_name"
  add_index "users", ["password_hash"], :name => "index_users_on_password_hash"
  add_index "users", ["recovery_token"], :name => "index_users_on_recovery_token"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"
  add_index "users", ["residence_country_id"], :name => "index_users_on_residence_country_id"
  add_index "users", ["tshirt_size_id"], :name => "index_users_on_tshirt_size_id"

end
