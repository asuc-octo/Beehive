class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  cattr_accessor :destroy_unused
  self.destroy_unused = false
  
  ***REMOVED*** LIKE is used for cross-database case-insensitivity
  def self.find_or_create_with_like_by_name(name)
    find(:first, :conditions => ["name LIKE ?", name]) || create(:name => name)
  end
  
  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end
  
  def to_s
    name
  end
  
  def count
    read_attribute(:count).to_i
  end
  
  class << self
    ***REMOVED*** Calculate the tag counts for all tags.
    ***REMOVED***  :start_at - Restrict the tags to those created after a certain time
    ***REMOVED***  :end_at - Restrict the tags to those created before a certain time
    ***REMOVED***  :conditions - A piece of SQL conditions to add to the query
    ***REMOVED***  :limit - The maximum number of tags to return
    ***REMOVED***  :order - A piece of SQL to order by. Eg 'count desc' or 'taggings.created_at desc'
    ***REMOVED***  :at_least - Exclude tags with a frequency less than the given value
    ***REMOVED***  :at_most - Exclude tags with a frequency greater than the given value
    def counts(options = {})
      find(:all, options_for_counts(options))
    end
    
    def options_for_counts(options = {})
      options.assert_valid_keys :start_at, :end_at, :conditions, :at_least, :at_most, :order, :limit, :joins
      options = options.dup
      
      start_at = sanitize_sql(["***REMOVED***{Tagging.table_name}.created_at >= ?", options.delete(:start_at)]) if options[:start_at]
      end_at = sanitize_sql(["***REMOVED***{Tagging.table_name}.created_at <= ?", options.delete(:end_at)]) if options[:end_at]
      
      conditions = [
        options.delete(:conditions),
        start_at,
        end_at
      ].compact
      
      conditions = conditions.any? ? conditions.join(' AND ') : nil
      
      joins = ["INNER JOIN ***REMOVED***{Tagging.table_name} ON ***REMOVED***{Tag.table_name}.id = ***REMOVED***{Tagging.table_name}.tag_id"]
      joins << options.delete(:joins) if options[:joins]
      
      at_least  = sanitize_sql(['COUNT(*) >= ?', options.delete(:at_least)]) if options[:at_least]
      at_most   = sanitize_sql(['COUNT(*) <= ?', options.delete(:at_most)]) if options[:at_most]
      having    = [at_least, at_most].compact.join(' AND ')
      group_by  = "***REMOVED***{Tag.table_name}.id, ***REMOVED***{Tag.table_name}.name HAVING COUNT(*) > 0"
      group_by << " AND ***REMOVED***{having}" unless having.blank?
      
      { :select     => "***REMOVED***{Tag.table_name}.id, ***REMOVED***{Tag.table_name}.name, COUNT(*) AS count", 
        :joins      => joins.join(" "),
        :conditions => conditions,
        :group      => group_by
      }.update(options)
    end
  end
end
