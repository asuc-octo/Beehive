module ThinkingSphinx
  class Index
    ***REMOVED*** The Builder class is the core for the index definition block processing.
    ***REMOVED*** There are four methods you really need to pay attention to:
    ***REMOVED*** - indexes
    ***REMOVED*** - has
    ***REMOVED*** - where
    ***REMOVED*** - set_property/set_properties
    ***REMOVED***
    ***REMOVED*** The first two of these methods allow you to define what data makes up
    ***REMOVED*** your indexes. ***REMOVED***where provides a method to add manual SQL conditions, and
    ***REMOVED*** set_property allows you to set some settings on a per-index basis. Check
    ***REMOVED*** out each method's documentation for better ideas of usage.
    ***REMOVED*** 
    class Builder
      instance_methods.grep(/^[^_]/).each { |method|
        next if method.to_s == "instance_eval"
        define_method(method) {
          caller.grep(/irb.completion/).empty? ? method_missing(method) : super
        }
      }
      
      def self.generate(model, name = nil, &block)
        index  = ThinkingSphinx::Index.new(model)
        index.name = name unless name.nil?
        
        Builder.new(index, &block) if block_given?
        
        index.delta_object = ThinkingSphinx::Deltas.parse index
        index
      end
      
      def initialize(index, &block)
        @index  = index
        @explicit_source = false
        
        self.instance_eval &block
        
        if no_fields?
          raise "At least one field is necessary for an index"
        end
      end
      
      def define_source(&block)
        if @explicit_source
          @source = ThinkingSphinx::Source.new(@index)
          @index.sources << @source
        else
          @explicit_source = true
        end
        
        self.instance_eval &block
      end
      
      ***REMOVED*** This is how you add fields - the strings Sphinx looks at - to your
      ***REMOVED*** index. Technically, to use this method, you need to pass in some
      ***REMOVED*** columns and options - but there's some neat method_missing stuff
      ***REMOVED*** happening, so lets stick to the expected syntax within a define_index
      ***REMOVED*** block.
      ***REMOVED***
      ***REMOVED*** Expected options are :as, which points to a column alias in symbol
      ***REMOVED*** form, and :sortable, which indicates whether you want to sort by this
      ***REMOVED*** field.
      ***REMOVED***
      ***REMOVED*** Adding Single-Column Fields:
      ***REMOVED*** 
      ***REMOVED*** You can use symbols or methods - and can chain methods together to
      ***REMOVED*** get access down the associations tree.
      ***REMOVED*** 
      ***REMOVED***   indexes :id, :as => :my_id
      ***REMOVED***   indexes :name, :sortable => true
      ***REMOVED***   indexes first_name, last_name, :sortable => true
      ***REMOVED***   indexes users.posts.content, :as => :post_content
      ***REMOVED***   indexes users(:id), :as => :user_ids
      ***REMOVED***
      ***REMOVED*** Keep in mind that if any keywords for Ruby methods - such as id or 
      ***REMOVED*** name - clash with your column names, you need to use the symbol
      ***REMOVED*** version (see the first, second and last examples above).
      ***REMOVED***
      ***REMOVED*** If you specify multiple columns (example ***REMOVED***2), a field will be created
      ***REMOVED*** for each. Don't use the :as option in this case. If you want to merge
      ***REMOVED*** those columns together, continue reading.
      ***REMOVED*** 
      ***REMOVED*** Adding Multi-Column Fields:
      ***REMOVED*** 
      ***REMOVED***   indexes [first_name, last_name], :as => :name
      ***REMOVED***   indexes [location, parent.location], :as => :location
      ***REMOVED***
      ***REMOVED*** To combine multiple columns into a single field, you need to wrap
      ***REMOVED*** them in an Array, as shown by the above examples. There's no
      ***REMOVED*** limitations on whether they're symbols or methods or what level of
      ***REMOVED*** associations they come from.
      ***REMOVED*** 
      ***REMOVED*** Adding SQL Fragment Fields
      ***REMOVED***
      ***REMOVED*** You can also define a field using an SQL fragment, useful for when
      ***REMOVED*** you would like to index a calculated value.
      ***REMOVED***
      ***REMOVED***   indexes "age < 18", :as => :minor
      ***REMOVED***
      def indexes(*args)
        options = args.extract_options!
        args.each do |columns|
          field = Field.new(source, FauxColumn.coerce(columns), options)
          
          add_sort_attribute  field, options   if field.sortable
          add_facet_attribute field, options   if field.faceted
        end
      end
      
      ***REMOVED*** This is the method to add attributes to your index (hence why it is
      ***REMOVED*** aliased as 'attribute'). The syntax is the same as ***REMOVED***indexes, so use
      ***REMOVED*** that as starting point, but keep in mind the following points.
      ***REMOVED*** 
      ***REMOVED*** An attribute can have an alias (the :as option), but it is always
      ***REMOVED*** sortable - so you don't need to explicitly request that. You _can_
      ***REMOVED*** specify the data type of the attribute (the :type option), but the
      ***REMOVED*** code's pretty good at figuring that out itself from peering into the
      ***REMOVED*** database.
      ***REMOVED*** 
      ***REMOVED*** Attributes are limited to the following types: integers, floats,
      ***REMOVED*** datetimes (converted to timestamps), booleans, strings and MVAs
      ***REMOVED*** (:multi). Don't forget that Sphinx converts string attributes to
      ***REMOVED*** integers, which are useful for sorting, but that's about it.
      ***REMOVED*** 
      ***REMOVED*** Collection of integers are known as multi-value attributes (MVAs).
      ***REMOVED*** Generally these would be through a has_many relationship, like in this
      ***REMOVED*** example:
      ***REMOVED*** 
      ***REMOVED***   has posts(:id), :as => :post_ids
      ***REMOVED*** 
      ***REMOVED*** This allows you to filter on any of the values tied to a specific
      ***REMOVED*** record. Might be best to read through the Sphinx documentation to get
      ***REMOVED*** a better idea of that though.
      ***REMOVED*** 
      ***REMOVED*** Adding SQL Fragment Attributes
      ***REMOVED***
      ***REMOVED*** You can also define an attribute using an SQL fragment, useful for
      ***REMOVED*** when you would like to index a calculated value. Don't forget to set
      ***REMOVED*** the type of the attribute though:
      ***REMOVED***
      ***REMOVED***   has "age < 18", :as => :minor, :type => :boolean
      ***REMOVED*** 
      ***REMOVED*** If you're creating attributes for latitude and longitude, don't
      ***REMOVED*** forget that Sphinx expects these values to be in radians.
      ***REMOVED*** 
      def has(*args)
        options = args.extract_options!
        args.each do |columns|
          attribute = Attribute.new(source, FauxColumn.coerce(columns), options)
          
          add_facet_attribute attribute, options if attribute.faceted
        end
      end
      
      def facet(*args)
        options = args.extract_options!
        options[:facet] = true
        
        args.each do |columns|
          attribute = Attribute.new(source, FauxColumn.coerce(columns), options)
          
          add_facet_attribute attribute, options
        end
      end
      
      def join(*args)
        args.each do |association|
          Join.new(source, association)
        end
      end
      
      ***REMOVED*** Use this method to add some manual SQL conditions for your index
      ***REMOVED*** request. You can pass in as many strings as you like, they'll get
      ***REMOVED*** joined together with ANDs later on.
      ***REMOVED*** 
      ***REMOVED***   where "user_id = 10"
      ***REMOVED***   where "parent_type = 'Article'", "created_at < NOW()"
      ***REMOVED*** 
      def where(*args)
        source.conditions += args
      end
      
      ***REMOVED*** Use this method to add some manual SQL strings to the GROUP BY
      ***REMOVED*** clause. You can pass in as many strings as you'd like, they'll get
      ***REMOVED*** joined together with commas later on.
      ***REMOVED*** 
      ***REMOVED***   group_by "lat", "lng"
      ***REMOVED*** 
      def group_by(*args)
        source.groupings += args
      end
      
      ***REMOVED*** This is what to use to set properties on the index. Chief amongst
      ***REMOVED*** those is the delta property - to allow automatic updates to your
      ***REMOVED*** indexes as new models are added and edited - but also you can
      ***REMOVED*** define search-related properties which will be the defaults for all
      ***REMOVED*** searches on the model.
      ***REMOVED*** 
      ***REMOVED***   set_property :delta => true
      ***REMOVED***   set_property :field_weights => {"name" => 100}
      ***REMOVED***   set_property :order => "name ASC"
      ***REMOVED***   set_property :select => 'name'
      ***REMOVED*** 
      ***REMOVED*** Also, the following two properties are particularly relevant for
      ***REMOVED*** geo-location searching - latitude_attr and longitude_attr. If your
      ***REMOVED*** attributes for these two values are named something other than
      ***REMOVED*** lat/latitude or lon/long/longitude, you can dictate what they are
      ***REMOVED*** when defining the index, so you don't need to specify them for every
      ***REMOVED*** geo-related search.
      ***REMOVED***
      ***REMOVED***   set_property :latitude_attr => "lt", :longitude_attr => "lg"
      ***REMOVED*** 
      ***REMOVED*** Please don't forget to add a boolean field named 'delta' to your
      ***REMOVED*** model's database table if enabling the delta index for it.
      ***REMOVED*** Valid options for the delta property are:
      ***REMOVED*** 
      ***REMOVED*** true
      ***REMOVED*** false
      ***REMOVED*** :default
      ***REMOVED*** :delayed
      ***REMOVED*** :datetime
      ***REMOVED*** 
      ***REMOVED*** You can also extend ThinkingSphinx::Deltas::DefaultDelta to implement 
      ***REMOVED*** your own handling for delta indexing.
      ***REMOVED*** 
      def set_property(*args)
        options = args.extract_options!
        options.each do |key, value|
          set_single_property key, value
        end
        
        set_single_property args[0], args[1] if args.length == 2
      end
      alias_method :set_properties, :set_property
      
      ***REMOVED*** Handles the generation of new columns for the field and attribute
      ***REMOVED*** definitions.
      ***REMOVED*** 
      def method_missing(method, *args)
        FauxColumn.new(method, *args)
      end
      
      ***REMOVED*** A method to allow adding fields from associations which have names
      ***REMOVED*** that clash with method names in the Builder class (ie: properties,
      ***REMOVED*** fields, attributes).
      ***REMOVED*** 
      ***REMOVED*** Example: indexes assoc(:properties).column
      ***REMOVED*** 
      def assoc(assoc, *args)
        FauxColumn.new(assoc, *args)
      end
      
      private
      
      def source
        @source ||= begin
          source = ThinkingSphinx::Source.new(@index)
          @index.sources << source
          source
        end
      end
      
      def set_single_property(key, value)
        source_options = ThinkingSphinx::Configuration::SourceOptions
        if source_options.include?(key.to_s)
          source.options.merge! key => value
        else
          @index.local_options.merge!  key => value
        end
      end
      
      def add_sort_attribute(field, options)
        add_internal_attribute field, options, "_sort"
      end
      
      def add_facet_attribute(property, options)
        add_internal_attribute property, options, "_facet", true
        @index.model.sphinx_facets << property.to_facet
      end
      
      def add_internal_attribute(property, options, suffix, crc = false)
        return unless ThinkingSphinx::Facet.translate?(property)
        
        Attribute.new(source,
          property.columns.collect { |col| col.clone },
          options.merge(
            :type => property.is_a?(Field) ? :string : options[:type],
            :as   => property.unique_name.to_s.concat(suffix).to_sym,
            :crc  => crc
          ).except(:facet)
        )
      end
      
      def no_fields?
        @index.sources.empty? || @index.sources.any? { |source|
          source.fields.length == 0
        }
      end
    end
  end
end
