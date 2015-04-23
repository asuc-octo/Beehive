***REMOVED*** This migration comes from acts_as_taggable_on_engine (originally 1)

***REMOVED*** 2015-4-23 allenz Manually modified this migration table so that it uses
***REMOVED*** existing tables from acts_as_taggable_on_steroids rather than creating
***REMOVED*** tables from scratch.
class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
    ***REMOVED*** create_table :tags do |t|
    ***REMOVED***   t.string :name
    ***REMOVED*** end

    ***REMOVED*** create_table :taggings do |t|
    change_table :taggings do |t|
      ***REMOVED*** t.references :tag

      ***REMOVED*** You should make sure that the column created is
      ***REMOVED*** long enough to store the required class names.
      ***REMOVED*** t.references :taggable, polymorphic: true
      t.references :tagger, polymorphic: true

      ***REMOVED*** Limit is created to prevent MySQL error on index
      ***REMOVED*** length for MyISAM table type: http://bit.ly/vgW2Ql
      t.string :context, limit: 128

      ***REMOVED*** t.datetime :created_at
    end

    ***REMOVED*** add_index :taggings, :tag_id
    remove_index :taggings, [:taggable_id, :taggable_type]
    add_index :taggings, [:taggable_id, :taggable_type, :context]
  end

  def self.down
    ***REMOVED*** drop_table :taggings
    ***REMOVED*** drop_table :tags
    remove_index :taggings, [:taggable_id, :taggable_type, :context]

    change_table :taggings do |t|
      t.remove_references :tagger, polymorphic: true
      t.remove :context
    end
    add_index :taggings, [:taggable_id, :taggable_type]
  end
end
