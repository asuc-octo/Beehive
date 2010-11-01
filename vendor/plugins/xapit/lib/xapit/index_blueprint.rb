module Xapit
  ***REMOVED*** This is the object used in the block of the xapit method in Xapit::Membership. It keeps track of the
  ***REMOVED*** index settings for a given class. It also provides some indexing functionality.
  class IndexBlueprint
    attr_reader :text_attributes
    attr_reader :field_attributes
    attr_reader :sortable_attributes
    attr_reader :facets
    
    ***REMOVED*** Indexes all classes known to have an index blueprint defined.
    def self.index_all
      load_models
      @@instances.each do |member_class, blueprint|
        yield(member_class) if block_given?
        blueprint.index_all
      end
    end
    
    def initialize(member_class, *args)
      @member_class = member_class
      @args = args
      @text_attributes = {}
      @field_attributes = []
      @sortable_attributes = []
      @facets = []
      @@instances ||= {}
      @@instances[member_class] = self ***REMOVED*** TODO make this thread safe
      @indexer = SimpleIndexer.new(self)
    end
    
    ***REMOVED*** Adds a text attribute. Each word in the text will be indexed as a separate term allowing full text searching.
    ***REMOVED*** Text terms are what is searched by the primary string in a search query.
    ***REMOVED***
    ***REMOVED***   Article.search("kite")
    ***REMOVED***
    ***REMOVED*** You can specify a :weight option to give a text attribute more importance. This will cause search terms matching
    ***REMOVED*** that attribute to have a higher rank. The default weight is 1. Decimal (0.5) weight values are not supported.
    ***REMOVED***
    ***REMOVED***   index.text :name, :weight => 10
    ***REMOVED*** 
    def text(*attributes, &proc)
      options = attributes.extract_options!
      options[:proc] ||= proc
      attributes.each do |attribute|
        @text_attributes[attribute] = options
      end
    end
    
    ***REMOVED*** Adds a field attribute. Field terms are not split by word so it is not designed for full text search.
    ***REMOVED*** Instead you can filter through a field using the :conditions hash in a search query.
    ***REMOVED***
    ***REMOVED***   Article.search(:conditions => { :priority => 5 })
    ***REMOVED*** 
    ***REMOVED*** Multiple field values are supported if the given attribute is an array.
    ***REMOVED*** 
    ***REMOVED***   def priority
    ***REMOVED***     [3, 5] ***REMOVED*** will match priority search for 3 or 5
    ***REMOVED***   end
    ***REMOVED*** 
    def field(*attributes)
      @field_attributes += attributes
    end
    
    ***REMOVED*** Adds a facet attribute. See Xapit::FacetBlueprint and Xapit::Facet for details.
    def facet(*args, &block)
      @facets << FacetBlueprint.new(@member_class, @facets.size, *args, &block)
    end
    
    ***REMOVED*** Adds a sortable attribute for use with the :order option in a search call.
    def sortable(*attributes)
      @sortable_attributes += attributes
    end
    
    ***REMOVED*** Indexes all records of this blueprint class. It does this using the ".find_each" method on the member class.
    ***REMOVED*** You will likely want to call Xapit.remove_database before this.
    def index_all
      @member_class.xapit_adapter.find_each(*@args) do |member|
        @indexer.add_member(member)
      end
    end
    
    ***REMOVED*** The Xapian value index position of a sortable attribute
    def position_of_sortable(sortable_attribute)
      index = sortable_attributes.map(&:to_s).index(sortable_attribute.to_s)
      raise "Unable to find indexed sortable attribute \"***REMOVED***{sortable_attribute}\" in ***REMOVED***{@member_class} sortable attributes: ***REMOVED***{sortable_attributes.inspect}" if index.nil?
      index + facets.size
    end
    
    ***REMOVED*** The Xapian value index position of a field attribute
    def position_of_field(field_attribute)
      index = field_attributes.map(&:to_s).index(field_attribute.to_s)
      raise "Unable to find indexed field attribute \"***REMOVED***{field_attribute}\" in ***REMOVED***{@member_class} field attributes: ***REMOVED***{field_attributes.inspect}" if index.nil?
      index + facets.size + sortable_attributes.size
    end
    
    ***REMOVED*** Add a single record to the index if it matches the xapit options.
    def create_record(member_id)
      member = @member_class.xapit_adapter.find_single(member_id, *@args)
      @indexer.add_member(member) if member
    end
    
    ***REMOVED*** Update a single record in the index. If the record does not match the xapit
    ***REMOVED*** conditions then it is removed from the index instead.
    def update_record(member_id)
      member = @member_class.xapit_adapter.find_single(member_id, *@args)
      if member
        @indexer.update_member(member)
      else
        destroy_record(member_id)
      end
    end
    
    ***REMOVED*** Remove a single record from the index.
    def destroy_record(member_id)
      Xapit::Config.writable_database.delete_document("Q***REMOVED***{@member_class}-***REMOVED***{member_id}")
    end
    
    private
    
    ***REMOVED*** Make sure all models are loaded - without reloading any that
    ***REMOVED*** ActiveRecord::Base is already aware of (otherwise we start to hit some
    ***REMOVED*** messy dependencies issues).
    ***REMOVED*** 
    ***REMOVED*** Taken from thinking-sphinx
    def self.load_models
      if defined? Rails
        base = "***REMOVED***{Rails.root}/app/models/"
        Dir["***REMOVED***{base}**/*.rb"].each do |file|
          model_name = file.gsub(/^***REMOVED***{base}([\w_\/\\]+)\.rb/, '\1')
      
          next if model_name.nil?
          next if ::ActiveRecord::Base.send(:subclasses).detect { |model|
            model.name == model_name
          }
      
          begin
            model_name.camelize.constantize
          rescue LoadError
            model_name.gsub!(/.*[\/\\]/, '').nil? ? next : retry
          rescue NameError
            next
          end
        end
      end
    end
  end
end
