class AddShibLoginToUsers < ActiveRecord::Migration
  def change
    add_column :users, :shib_login, :string
  end
end
