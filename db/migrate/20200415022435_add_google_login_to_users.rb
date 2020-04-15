class AddGoogleLoginToUsers < ActiveRecord::Migration
  def change
    add_column :users, :google_login, :string
  end
end
