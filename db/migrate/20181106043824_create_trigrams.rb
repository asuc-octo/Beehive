class CreateTrigrams < ActiveRecord::Migration
  def change
    create_table :trigrams do |t|

      t.timestamps null: false
    end
  end
end
