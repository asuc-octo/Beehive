require 'thinking_sphinx/active_record/attribute_updates'
require 'thinking_sphinx/active_record/delta'
require 'thinking_sphinx/active_record/has_many_association'
require 'thinking_sphinx/active_record/scopes'

module ThinkingSphinx
  ***REMOVED*** Core additions to ActiveRecord models - define_index for creating indexes
  ***REMOVED*** for models. If you want to interrogate the index objects created for the
  ***REMOVED*** model, you can use the class-level accessor :sphinx_indexes.
  ***REMOVED***
  module ActiveRecord
    def self.included(base)
      base.class_eval do
        class_inheritable_array :sphinx_indexes, :sphinx_facets
        
        extend ThinkingSphinx::ActiveRecord::ClassMethods
        
        class << self
          attr_accessor :sphinx_index_blocks
          
          def set_sphinx_primary_key(attribute)
            @sphinx_primary_key_attribute = attribute
          end
          
          def primary_key_for_sphinx
            @sphinx_primary_key_attribute || primary_key
          end
          
          def sphinx_index_options
            sphinx_indexes.last.options
          end
          
          ***REMOVED*** Generate a unique CRC value for the model's name, to use to
          ***REMOVED*** determine which Sphinx documents belong to which AR records.
          ***REMOVED*** 
          ***REMOVED*** Really only written for internal use - but hey, if it's useful to
          ***REMOVED*** you in some other way, awesome.
          ***REMOVED*** 
          def to_crc32
            self.name.to_crc32
          end
          
          def to_crc32s
            (subclasses << self).collect { |klass| klass.to_crc32 }
          end
          
          def sphinx_database_adapter
            @sphinx_database_adapter ||=
              ThinkingSphinx::AbstractAdapter.detect(self)
          end
          
          def sphinx_name
            self.name.underscore.tr(':/\\', '_')
          end
          
          ***REMOVED***
          ***REMOVED*** The above method to_crc32s is dependant on the subclasses being loaded consistently
          ***REMOVED*** After a reset_subclasses is called (during a Dispatcher.cleanup_application in development)
          ***REMOVED*** Our subclasses will be lost but our context will not reload them for us.
          ***REMOVED***
          ***REMOVED*** We reset the context which causes the subclasses to be reloaded next time the context is called.
          ***REMOVED***
          def reset_subclasses_with_thinking_sphinx
            reset_subclasses_without_thinking_sphinx
            ThinkingSphinx.reset_context!
          end
          
          alias_method_chain :reset_subclasses, :thinking_sphinx
          
          private
          
          def defined_indexes?
            @defined_indexes
          end
          
          def defined_indexes=(value)
            @defined_indexes = value
          end
          
          def sphinx_delta?
            self.sphinx_indexes.any? { |index| index.delta? }
          end
        end
      end
      
      ::ActiveRecord::Associations::HasManyAssociation.send(
        :include, ThinkingSphinx::ActiveRecord::HasManyAssociation
      )
      ::ActiveRecord::Associations::HasManyThroughAssociation.send(
        :include, ThinkingSphinx::ActiveRecord::HasManyAssociation
      )
    end
    
    module ClassMethods
      ***REMOVED*** Allows creation of indexes for Sphinx. If you don't do this, there
      ***REMOVED*** isn't much point trying to search (or using this plugin at all,
      ***REMOVED*** really).
      ***REMOVED***
      ***REMOVED*** An example or two:
      ***REMOVED***
      ***REMOVED***   define_index
      ***REMOVED***     indexes :id, :as => :model_id
      ***REMOVED***     indexes name
      ***REMOVED***   end
      ***REMOVED***
      ***REMOVED*** You can also grab fields from associations - multiple levels deep
      ***REMOVED*** if necessary.
      ***REMOVED***
      ***REMOVED***   define_index do
      ***REMOVED***     indexes tags.name, :as => :tag
      ***REMOVED***     indexes articles.content
      ***REMOVED***     indexes orders.line_items.product.name, :as => :product
      ***REMOVED***   end
      ***REMOVED***
      ***REMOVED*** And it will automatically concatenate multiple fields:
      ***REMOVED***
      ***REMOVED***   define_index do
      ***REMOVED***     indexes [author.first_name, author.last_name], :as => :author
      ***REMOVED***   end
      ***REMOVED***
      ***REMOVED*** The ***REMOVED***indexes method is for fields - if you want attributes, use
      ***REMOVED*** ***REMOVED***has instead. All the same rules apply - but keep in mind that
      ***REMOVED*** attributes are for sorting, grouping and filtering, not searching.
      ***REMOVED***
      ***REMOVED***   define_index do
      ***REMOVED***     ***REMOVED*** fields ...
      ***REMOVED***     
      ***REMOVED***     has created_at, updated_at
      ***REMOVED***   end
      ***REMOVED***
      ***REMOVED*** One last feature is the delta index. This requires the model to
      ***REMOVED*** have a boolean field named 'delta', and is enabled as follows:
      ***REMOVED***
      ***REMOVED***   define_index do
      ***REMOVED***     ***REMOVED*** fields ...
      ***REMOVED***     ***REMOVED*** attributes ...
      ***REMOVED***     
      ***REMOVED***     set_property :delta => true
      ***REMOVED***   end
      ***REMOVED***
      ***REMOVED*** Check out the more detailed documentation for each of these methods
      ***REMOVED*** at ThinkingSphinx::Index::Builder.
      ***REMOVED*** 
      def define_index(name = nil, &block)
        self.sphinx_index_blocks ||= []
        self.sphinx_indexes      ||= []
        self.sphinx_facets       ||= []
        
        ThinkingSphinx.context.add_indexed_model self
        
        if sphinx_index_blocks.empty?
          before_validation :define_indexes
          before_destroy    :define_indexes
        end
        
        self.sphinx_index_blocks << lambda {
          add_sphinx_index name, &block
        }
        
        include ThinkingSphinx::ActiveRecord::Scopes
        include ThinkingSphinx::SearchMethods
      end
      
      def define_indexes
        superclass.define_indexes unless superclass == ::ActiveRecord::Base
        
        return if sphinx_index_blocks.nil? ||
          defined_indexes?                 ||
          !ThinkingSphinx.define_indexes?
        
        sphinx_index_blocks.each do |block|
          block.call
        end
        
        self.defined_indexes = true
        
        ***REMOVED*** We want to make sure that if the database doesn't exist, then Thinking
        ***REMOVED*** Sphinx doesn't mind when running non-TS tasks (like db:create, db:drop
        ***REMOVED*** and db:migrate). It's a bit hacky, but I can't think of a better way.
      rescue StandardError => err
        case err.class.name
        when "Mysql::Error", "Java::JavaSql::SQLException", "ActiveRecord::StatementInvalid"
          return
        else
          raise err
        end
      end
      
      def add_sphinx_index(name, &block)
        index = ThinkingSphinx::Index::Builder.generate self, name, &block

        unless sphinx_indexes.any? { |i| i.name == index.name }
          add_sphinx_callbacks_and_extend(index.delta?)
          insert_sphinx_index index
        end
      end
      
      def insert_sphinx_index(index)
        self.sphinx_indexes << index
        subclasses.each { |klass| klass.insert_sphinx_index(index) }
      end
      
      def has_sphinx_indexes?
        sphinx_indexes      && 
        sphinx_index_blocks &&
        (sphinx_indexes.length > 0 || sphinx_index_blocks.length > 0)
      end
      
      def indexed_by_sphinx?
        sphinx_indexes && sphinx_indexes.length > 0
      end
      
      def delta_indexed_by_sphinx?
        sphinx_indexes && sphinx_indexes.any? { |index| index.delta? }
      end
      
      def sphinx_index_names
        define_indexes
        sphinx_indexes.collect(&:all_names).flatten
      end
      
      def core_index_names
        define_indexes
        sphinx_indexes.collect(&:core_name)
      end
      
      def delta_index_names
        define_indexes
        sphinx_indexes.select(&:delta?).collect(&:delta_name)
      end
      
      def to_riddle
        define_indexes
        sphinx_database_adapter.setup
        
        local_sphinx_indexes.collect { |index|
          index.to_riddle(sphinx_offset)
        }.flatten
      end
      
      def source_of_sphinx_index
        define_indexes
        possible_models = self.sphinx_indexes.collect { |index| index.model }
        return self if possible_models.include?(self)

        parent = self.superclass
        while !possible_models.include?(parent) && parent != ::ActiveRecord::Base
          parent = parent.superclass
        end

        return parent
      end
      
      def delete_in_index(index, document_id)
        return unless ThinkingSphinx.sphinx_running? &&
          search_for_id(document_id, index)
        
        ThinkingSphinx::Configuration.instance.client.update(
          index, ['sphinx_deleted'], {document_id => [1]}
        )
      end
      
      def sphinx_offset
        ThinkingSphinx.context.superclass_indexed_models.
          index eldest_indexed_ancestor
      end
      
      ***REMOVED*** Temporarily disable delta indexing inside a block, then perform a single
      ***REMOVED*** rebuild of index at the end.
      ***REMOVED***
      ***REMOVED*** Useful when performing updates to batches of models to prevent
      ***REMOVED*** the delta index being rebuilt after each individual update.
      ***REMOVED***
      ***REMOVED*** In the following example, the delta index will only be rebuilt once,
      ***REMOVED*** not 10 times.
      ***REMOVED***
      ***REMOVED***   SomeModel.suspended_delta do
      ***REMOVED***     10.times do
      ***REMOVED***       SomeModel.create( ... )
      ***REMOVED***     end
      ***REMOVED***   end
      ***REMOVED***
      def suspended_delta(reindex_after = true, &block)
        define_indexes
        original_setting = ThinkingSphinx.deltas_enabled?
        ThinkingSphinx.deltas_enabled = false
        begin
          yield
        ensure
          ThinkingSphinx.deltas_enabled = original_setting
          self.index_delta if reindex_after
        end
      end
      
      private
            
      def local_sphinx_indexes
        sphinx_indexes.select { |index|
          index.model == self
        }
      end
      
      def add_sphinx_callbacks_and_extend(delta = false)
        unless indexed_by_sphinx?
          after_destroy :toggle_deleted
          
          include ThinkingSphinx::ActiveRecord::AttributeUpdates
        end
        
        if delta && !delta_indexed_by_sphinx?
          include ThinkingSphinx::ActiveRecord::Delta
          
          before_save   :toggle_delta
          after_commit  :index_delta
        end
      end
      
      def eldest_indexed_ancestor
        ancestors.reverse.detect { |ancestor|
          ThinkingSphinx.context.indexed_models.include?(ancestor.name)
        }.name
      end
    end
    
    attr_accessor :excerpts
    attr_accessor :sphinx_attributes
    attr_accessor :matching_fields
    
    def in_index?(suffix)
      self.class.search_for_id self.sphinx_document_id, sphinx_index_name(suffix)
    end
    
    def in_core_index?
      in_index? "core"
    end
    
    def in_delta_index?
      in_index? "delta"
    end
    
    def in_both_indexes?
      in_core_index? && in_delta_index?
    end
    
    def toggle_deleted
      return unless ThinkingSphinx.updates_enabled?
      
      self.class.core_index_names.each do |index_name|
        self.class.delete_in_index index_name, self.sphinx_document_id
      end
      self.class.delta_index_names.each do |index_name|
        self.class.delete_in_index index_name, self.sphinx_document_id
      end if self.class.delta_indexed_by_sphinx? && toggled_delta?
      
    rescue ::ThinkingSphinx::ConnectionError
      ***REMOVED*** nothing
    end
    
    ***REMOVED*** Returns the unique integer id for the object. This method uses the
    ***REMOVED*** attribute hash to get around ActiveRecord always mapping the ***REMOVED***id method
    ***REMOVED*** to whatever the real primary key is (which may be a unique string hash).
    ***REMOVED*** 
    ***REMOVED*** @return [Integer] Unique record id for the purposes of Sphinx.
    ***REMOVED*** 
    def primary_key_for_sphinx
      read_attribute(self.class.primary_key_for_sphinx)
    end
    
    def sphinx_document_id
      primary_key_for_sphinx * ThinkingSphinx.context.indexed_models.size +
        self.class.sphinx_offset
    end

    private

    def sphinx_index_name(suffix)
      "***REMOVED***{self.class.source_of_sphinx_index.name.underscore.tr(':/\\', '_')}_***REMOVED***{suffix}"
    end
    
    def define_indexes
      self.class.define_indexes
    end
  end
end
