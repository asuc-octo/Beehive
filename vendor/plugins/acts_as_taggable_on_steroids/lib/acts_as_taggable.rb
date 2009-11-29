module ActiveRecord ***REMOVED***:nodoc:
  module Acts ***REMOVED***:nodoc:
    module Taggable ***REMOVED***:nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_taggable
          has_many :taggings, :as => :taggable, :dependent => :destroy, :include => :tag
          has_many :tags, :through => :taggings
          
          before_save :save_cached_tag_list
          
          after_create :save_tags
          after_update :save_tags
          
          include ActiveRecord::Acts::Taggable::InstanceMethods
          extend ActiveRecord::Acts::Taggable::SingletonMethods
          
          alias_method_chain :reload, :tag_list
        end
        
        def cached_tag_list_column_name
          "cached_tag_list"
        end
        
        def set_cached_tag_list_column_name(value = nil, &block)
          define_attr_method :cached_tag_list_column_name, value, &block
        end
      end
      
      module SingletonMethods
        ***REMOVED*** Returns an array of related tags.
        ***REMOVED*** Related tags are all the other tags that are found on the models tagged with the provided tags.
        ***REMOVED*** 
        ***REMOVED*** Pass either a tag, string, or an array of strings or tags.
        ***REMOVED*** 
        ***REMOVED*** Options:
        ***REMOVED***   :order - SQL Order how to order the tags. Defaults to "count DESC, tags.name".
        def find_related_tags(tags, options = {})
          tags = tags.is_a?(Array) ? TagList.new(tags.map(&:to_s)) : TagList.from(tags)
          
          related_models = find_tagged_with(tags)
          
          return [] if related_models.blank?
          
          related_ids = related_models.to_s(:db)
          
          Tag.find(:all, options.merge({
            :select => "***REMOVED***{Tag.table_name}.*, COUNT(***REMOVED***{Tag.table_name}.id) AS count",
            :joins  => "JOIN ***REMOVED***{Tagging.table_name} ON ***REMOVED***{Tagging.table_name}.taggable_type = '***REMOVED***{base_class.name}'
              AND  ***REMOVED***{Tagging.table_name}.taggable_id IN (***REMOVED***{related_ids})
              AND  ***REMOVED***{Tagging.table_name}.tag_id = ***REMOVED***{Tag.table_name}.id",
            :order => options[:order] || "count DESC, ***REMOVED***{Tag.table_name}.name",
            :group => "***REMOVED***{Tag.table_name}.id, ***REMOVED***{Tag.table_name}.name HAVING ***REMOVED***{Tag.table_name}.name NOT IN (***REMOVED***{tags.map { |n| quote_value(n) }.join(",")})"
          }))
        end
        
        ***REMOVED*** Pass either a tag, string, or an array of strings or tags.
        ***REMOVED*** 
        ***REMOVED*** Options:
        ***REMOVED***   :exclude - Find models that are not tagged with the given tags
        ***REMOVED***   :match_all - Find models that match all of the given tags, not just one
        ***REMOVED***   :conditions - A piece of SQL conditions to add to the query
        def find_tagged_with(*args)
          options = find_options_for_find_tagged_with(*args)
          options.blank? ? [] : find(:all, options)
        end
        
        def find_options_for_find_tagged_with(tags, options = {})
          tags = tags.is_a?(Array) ? TagList.new(tags.map(&:to_s)) : TagList.from(tags)
          options = options.dup
          
          return {} if tags.empty?
          
          conditions = []
          conditions << sanitize_sql(options.delete(:conditions)) if options[:conditions]
          
          taggings_alias, tags_alias = "***REMOVED***{table_name}_taggings", "***REMOVED***{table_name}_tags"
          
          joins = [
            "INNER JOIN ***REMOVED***{Tagging.table_name} ***REMOVED***{taggings_alias} ON ***REMOVED***{taggings_alias}.taggable_id = ***REMOVED***{table_name}.***REMOVED***{primary_key} AND ***REMOVED***{taggings_alias}.taggable_type = ***REMOVED***{quote_value(base_class.name)}",
            "INNER JOIN ***REMOVED***{Tag.table_name} ***REMOVED***{tags_alias} ON ***REMOVED***{tags_alias}.id = ***REMOVED***{taggings_alias}.tag_id"
          ]
          
          if options.delete(:exclude)
            conditions << <<-END
              ***REMOVED***{table_name}.id NOT IN
                (SELECT ***REMOVED***{Tagging.table_name}.taggable_id FROM ***REMOVED***{Tagging.table_name}
                 INNER JOIN ***REMOVED***{Tag.table_name} ON ***REMOVED***{Tagging.table_name}.tag_id = ***REMOVED***{Tag.table_name}.id
                 WHERE ***REMOVED***{tags_condition(tags)} AND ***REMOVED***{Tagging.table_name}.taggable_type = ***REMOVED***{quote_value(base_class.name)})
            END
          else
            if options.delete(:match_all)
              joins << joins_for_match_all_tags(tags)
            else
              conditions << tags_condition(tags, tags_alias)
            end
          end
          
          { :select => "DISTINCT ***REMOVED***{table_name}.*",
            :joins => joins.join(" "),
            :conditions => conditions.join(" AND ")
          }.reverse_merge!(options)
        end
        
        def joins_for_match_all_tags(tags)
          joins = []
          
          tags.each_with_index do |tag, index|
            taggings_alias, tags_alias = "taggings_***REMOVED***{index}", "tags_***REMOVED***{index}"

            join = <<-END
              INNER JOIN ***REMOVED***{Tagging.table_name} ***REMOVED***{taggings_alias} ON
                ***REMOVED***{taggings_alias}.taggable_id = ***REMOVED***{table_name}.***REMOVED***{primary_key} AND
                ***REMOVED***{taggings_alias}.taggable_type = ***REMOVED***{quote_value(base_class.name)}

              INNER JOIN ***REMOVED***{Tag.table_name} ***REMOVED***{tags_alias} ON
                ***REMOVED***{taggings_alias}.tag_id = ***REMOVED***{tags_alias}.id AND
                ***REMOVED***{tags_alias}.name = ?
            END

            joins << sanitize_sql([join, tag])
          end
          
          joins.join(" ")
        end
        
        ***REMOVED*** Calculate the tag counts for all tags.
        ***REMOVED*** 
        ***REMOVED*** See Tag.counts for available options.
        def tag_counts(options = {})
          Tag.find(:all, find_options_for_tag_counts(options))
        end
        
        def find_options_for_tag_counts(options = {})
          options = options.dup
          scope = scope(:find)
          
          conditions = []
          conditions << send(:sanitize_conditions, options.delete(:conditions)) if options[:conditions]
          conditions << send(:sanitize_conditions, scope[:conditions]) if scope && scope[:conditions]
          conditions << "***REMOVED***{Tagging.table_name}.taggable_type = ***REMOVED***{quote_value(base_class.name)}"
          conditions << type_condition unless descends_from_active_record? 
          conditions.compact!
          conditions = conditions.join(" AND ")
          
          joins = ["INNER JOIN ***REMOVED***{table_name} ON ***REMOVED***{table_name}.***REMOVED***{primary_key} = ***REMOVED***{Tagging.table_name}.taggable_id"]
          joins << options.delete(:joins) if options[:joins]
          joins << scope[:joins] if scope && scope[:joins]
          joins = joins.join(" ")
          
          options = { :conditions => conditions, :joins => joins }.update(options)
          
          Tag.options_for_counts(options)
        end
        
        def caching_tag_list?
          column_names.include?(cached_tag_list_column_name)
        end
        
       private
        def tags_condition(tags, table_name = Tag.table_name)
          condition = tags.map { |t| sanitize_sql(["***REMOVED***{table_name}.name LIKE ?", t]) }.join(" OR ")
          "(" + condition + ")" unless condition.blank?
        end
      end
      
      module InstanceMethods
        def tag_list
          return @tag_list if @tag_list
          
          if self.class.caching_tag_list? and !(cached_value = send(self.class.cached_tag_list_column_name)).nil?
            @tag_list = TagList.from(cached_value)
          else
            @tag_list = TagList.new(*tags.map(&:name))
          end
        end
        
        def tag_list=(value)
          @tag_list = TagList.from(value)
        end
        
        def save_cached_tag_list
          if self.class.caching_tag_list?
            self[self.class.cached_tag_list_column_name] = tag_list.to_s
          end
        end
        
        def save_tags
          return unless @tag_list
          
          new_tag_names = @tag_list - tags.map(&:name)
          old_tags = tags.reject { |tag| @tag_list.include?(tag.name) }
          
          self.class.transaction do
            if old_tags.any?
              taggings.find(:all, :conditions => ["tag_id IN (?)", old_tags.map(&:id)]).each(&:destroy)
              taggings.reset
            end
            
            new_tag_names.each do |new_tag_name|
              tags << Tag.find_or_create_with_like_by_name(new_tag_name)
            end
          end
          
          true
        end
        
        ***REMOVED*** Calculate the tag counts for the tags used by this model.
        ***REMOVED***
        ***REMOVED*** The possible options are the same as the tag_counts class method.
        def tag_counts(options = {})
          return [] if tag_list.blank?
          
          options[:conditions] = self.class.send(:merge_conditions, options[:conditions], self.class.send(:tags_condition, tag_list))
          self.class.tag_counts(options)
        end
        
        def reload_with_tag_list(*args) ***REMOVED***:nodoc:
          @tag_list = nil
          reload_without_tag_list(*args)
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Taggable)
