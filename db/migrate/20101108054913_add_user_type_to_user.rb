class AddUserTypeToUser < ActiveRecord::Migration
  def self.up
    ***REMOVED*** User level is in ascending order of power.
    ***REMOVED*** 0 = undergrad            -- can view posts, apply
    ***REMOVED*** 1 = grad student/postdoc -- can also post
    ***REMOVED*** 2 = faculty              -- can also approve posts
    ***REMOVED***
    ***REMOVED*** This migration converts is_faculty to (user_type=>2).
    ***REMOVED***
    add_column :users, :user_type, :integer, { :default => 0, :null => false }
    User.all.each { |user| user.update_attribute(:user_type, 2) if user.is_faculty }
    remove_column :users, :is_faculty
  end

  def self.down
    ***REMOVED*** Converts user level 2 to faculty.
    ***REMOVED*** All grad students/postdocs would then be non-faculty.
    ***REMOVED***
    add_column :users, :is_faculty, :boolean, { :default => false, :null => false }
    User.all.each { |user| user.update_attribute(:is_faculty, true) if user.user_type == 2 }
    remove_column :users, :user_type
  end
end
