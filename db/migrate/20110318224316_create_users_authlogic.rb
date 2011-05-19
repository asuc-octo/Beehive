class CreateUsersAuthlogic < ActiveRecord::Migration
  ***REMOVED*** https://github.com/binarylogic/authlogic_example
  ***REMOVED*** with some additional things

  def self.up
    drop_table 'users'

    create_table "users", :force => true do |t|
      t.string :name

      t.string    :login,               :null => false                ***REMOVED*** optional, you can use email instead, or both
      t.string    :email,               :null => false                ***REMOVED*** optional, you can use login instead, or both
      ***REMOVED*** t.string    :crypted_password,    :null => false                ***REMOVED*** optional, see below
      ***REMOVED*** t.string    :password_salt,       :null => false                ***REMOVED*** optional, but highly recommended
      t.string    :persistence_token,   :null => false                ***REMOVED*** required
      t.string    :single_access_token, :null => false                ***REMOVED*** optional, see Authlogic::Session::Params
      t.string    :perishable_token,    :null => false                ***REMOVED*** optional, see Authlogic::Session::Perishability

      ***REMOVED*** Magic columns, just like ActiveRecord's created_at and updated_at. These are automatically maintained by Authlogic if they are present.
      t.integer   :login_count,         :null => false, :default => 0 ***REMOVED*** optional, see Authlogic::Session::MagicColumns
      t.integer   :failed_login_count,  :null => false, :default => 0 ***REMOVED*** optional, see Authlogic::Session::MagicColumns
      t.datetime  :last_request_at                                    ***REMOVED*** optional, see Authlogic::Session::MagicColumns
      t.datetime  :current_login_at                                   ***REMOVED*** optional, see Authlogic::Session::MagicColumns
      t.datetime  :last_login_at                                      ***REMOVED*** optional, see Authlogic::Session::MagicColumns
      t.string    :current_login_ip                                   ***REMOVED*** optional, see Authlogic::Session::MagicColumns
      t.string    :last_login_ip                                      ***REMOVED*** optional, see Authlogic::Session::MagicColumns

      ***REMOVED*** ResearchMatch specifics
      t.integer   :user_type,           :null => false, :default => 0 ***REMOVED*** See User::Types
    end
    add_index :users, :login, :unique => true
  end

  def self.down
    drop_table "users"
  end
end

