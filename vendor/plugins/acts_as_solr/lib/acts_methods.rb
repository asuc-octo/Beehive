module ActsAsSolr ***REMOVED***:nodoc:
  
  module ActsMethods
    
    ***REMOVED*** declares a class as solr-searchable
    ***REMOVED*** 
    ***REMOVED*** ==== options:
    ***REMOVED*** fields:: This option can be used to specify only the fields you'd
    ***REMOVED***          like to index. If not given, all the attributes from the 
    ***REMOVED***          class will be indexed. You can also use this option to 
    ***REMOVED***          include methods that should be indexed as fields
    ***REMOVED*** 
    ***REMOVED***           class Movie < ActiveRecord::Base
    ***REMOVED***             acts_as_solr :fields => [:name, :description, :current_time]
    ***REMOVED***             def current_time
    ***REMOVED***               Time.now.to_s
    ***REMOVED***             end
    ***REMOVED***           end
    ***REMOVED***          
    ***REMOVED***          Each field passed can also be a hash with the value being a field type
    ***REMOVED*** 
    ***REMOVED***           class Electronic < ActiveRecord::Base
    ***REMOVED***             acts_as_solr :fields => [{:price => :range_float}]
    ***REMOVED***             def current_time
    ***REMOVED***               Time.now
    ***REMOVED***             end
    ***REMOVED***           end
    ***REMOVED*** 
    ***REMOVED***          The field types accepted are:
    ***REMOVED*** 
    ***REMOVED***          :float:: Index the field value as a float (ie.: 12.87)
    ***REMOVED***          :integer:: Index the field value as an integer (ie.: 31)
    ***REMOVED***          :boolean:: Index the field value as a boolean (ie.: true/false)
    ***REMOVED***          :date:: Index the field value as a date (ie.: Wed Nov 15 23:13:03 PST 2006)
    ***REMOVED***          :string:: Index the field value as a text string, not applying the same indexing
    ***REMOVED***                    filters as a regular text field
    ***REMOVED***          :range_integer:: Index the field value for integer range queries (ie.:[5 TO 20])
    ***REMOVED***          :range_float:: Index the field value for float range queries (ie.:[14.56 TO 19.99])
    ***REMOVED*** 
    ***REMOVED***          Setting the field type preserves its original type when indexed
    ***REMOVED*** 
    ***REMOVED***          The field may also be passed with a hash value containing options
    ***REMOVED***
    ***REMOVED***          class Author < ActiveRecord::Base
    ***REMOVED***            acts_as_solr :fields => [{:full_name => {:type => :text, :as => :name}}]
    ***REMOVED***            def full_name
    ***REMOVED***              self.first_name + ' ' + self.last_name
    ***REMOVED***            end
    ***REMOVED***          end
    ***REMOVED***
    ***REMOVED***          The options accepted are:
    ***REMOVED***
    ***REMOVED***          :type:: Index the field using the specified type
    ***REMOVED***          :as:: Index the field using the specified field name
    ***REMOVED***
    ***REMOVED*** additional_fields:: This option takes fields to be include in the index
    ***REMOVED***                     in addition to those derived from the database. You
    ***REMOVED***                     can also use this option to include custom fields 
    ***REMOVED***                     derived from methods you define. This option will be
    ***REMOVED***                     ignored if the :fields option is given. It also accepts
    ***REMOVED***                     the same field types as the option above
    ***REMOVED*** 
    ***REMOVED***                      class Movie < ActiveRecord::Base
    ***REMOVED***                       acts_as_solr :additional_fields => [:current_time]
    ***REMOVED***                       def current_time
    ***REMOVED***                         Time.now.to_s
    ***REMOVED***                       end
    ***REMOVED***                      end
    ***REMOVED*** 
    ***REMOVED*** exclude_fields:: This option taks an array of fields that should be ignored from indexing:
    ***REMOVED*** 
    ***REMOVED***                    class User < ActiveRecord::Base
    ***REMOVED***                      acts_as_solr :exclude_fields => [:password, :login, :credit_card_number]
    ***REMOVED***                    end
    ***REMOVED*** 
    ***REMOVED*** include:: This option can be used for association indexing, which 
    ***REMOVED***           means you can include any :has_one, :has_many, :belongs_to 
    ***REMOVED***           and :has_and_belongs_to_many association to be indexed:
    ***REMOVED*** 
    ***REMOVED***            class Category < ActiveRecord::Base
    ***REMOVED***              has_many :books
    ***REMOVED***              acts_as_solr :include => [:books]
    ***REMOVED***            end
    ***REMOVED*** 
    ***REMOVED***           Each association may also be specified as a hash with an option hash as a value
    ***REMOVED***
    ***REMOVED***           class Book < ActiveRecord::Base
    ***REMOVED***             belongs_to :author
    ***REMOVED***             has_many :distribution_companies
    ***REMOVED***             has_many :copyright_dates
    ***REMOVED***             has_many :media_types
    ***REMOVED***             acts_as_solr(
    ***REMOVED***               :fields => [:name, :description],
    ***REMOVED***               :include => [
    ***REMOVED***                 {:author => {:using => :fullname, :as => :name}},
    ***REMOVED***                 {:media_types => {:using => lambda{|media| type_lookup(media.id)}}}
    ***REMOVED***                 {:distribution_companies => {:as => :distributor, :multivalued => true}},
    ***REMOVED***                 {:copyright_dates => {:as => :copyright, :type => :date}}
    ***REMOVED***               ]
    ***REMOVED***             ]
    ***REMOVED***
    ***REMOVED***           The options accepted are:
    ***REMOVED***
    ***REMOVED***           :type:: Index the associated objects using the specified type
    ***REMOVED***           :as:: Index the associated objects using the specified field name
    ***REMOVED***           :using:: Index the associated objects using the value returned by the specified method or proc.  If a method
    ***REMOVED***                    symbol is supplied, it will be sent to each object to look up the value to index; if a proc is
    ***REMOVED***                    supplied, it will be called once for each object with the object as the only argument
    ***REMOVED***           :multivalued:: Index the associated objects using one field for each object rather than joining them
    ***REMOVED***                          all into a single field
    ***REMOVED***
    ***REMOVED*** facets:: This option can be used to specify the fields you'd like to
    ***REMOVED***          index as facet fields
    ***REMOVED*** 
    ***REMOVED***           class Electronic < ActiveRecord::Base
    ***REMOVED***             acts_as_solr :facets => [:category, :manufacturer]  
    ***REMOVED***           end
    ***REMOVED*** 
    ***REMOVED*** boost:: You can pass a boost (float) value that will be used to boost the document and/or a field. To specify a more
    ***REMOVED***         boost for the document, you can either pass a block or a symbol. The block will be called with the record
    ***REMOVED***         as an argument, a symbol will result in the according method being called:
    ***REMOVED*** 
    ***REMOVED***           class Electronic < ActiveRecord::Base
    ***REMOVED***             acts_as_solr :fields => [{:price => {:boost => 5.0}}], :boost => 10.0
    ***REMOVED***           end
    ***REMOVED*** 
    ***REMOVED***           class Electronic < ActiveRecord::Base
    ***REMOVED***             acts_as_solr :fields => [{:price => {:boost => 5.0}}], :boost => proc {|record| record.id + 120*37}
    ***REMOVED***           end
    ***REMOVED***
    ***REMOVED***           class Electronic < ActiveRecord::Base
    ***REMOVED***             acts_as_solr :fields => [{:price => {:boost => :price_rating}}], :boost => 10.0
    ***REMOVED***           end
    ***REMOVED***
    ***REMOVED*** if:: Only indexes the record if the condition evaluated is true. The argument has to be 
    ***REMOVED***      either a symbol, string (to be eval'ed), proc/method, or class implementing a static 
    ***REMOVED***      validation method. It behaves the same way as ActiveRecord's :if option.
    ***REMOVED*** 
    ***REMOVED***        class Electronic < ActiveRecord::Base
    ***REMOVED***          acts_as_solr :if => proc{|record| record.is_active?}
    ***REMOVED***        end
    ***REMOVED*** 
    ***REMOVED*** offline:: Assumes that your using an outside mechanism to explicitly trigger indexing records, e.g. you only
    ***REMOVED***           want to update your index through some asynchronous mechanism. Will accept either a boolean or a block
    ***REMOVED***           that will be evaluated before actually contacting the index for saving or destroying a document. Defaults
    ***REMOVED***           to false. It doesn't refer to the mechanism of an offline index in general, but just to get a centralized point
    ***REMOVED***           where you can control indexing. Note: This is only enabled for saving records. acts_as_solr doesn't always like
    ***REMOVED***           it, if you have a different number of results coming from the database and the index. This might be rectified in
    ***REMOVED***           another patch to support lazy loading.
    ***REMOVED***
    ***REMOVED***             class Electronic < ActiveRecord::Base
    ***REMOVED***               acts_as_solr :offline => proc {|record| record.automatic_indexing_disabled?}
    ***REMOVED***             end
    ***REMOVED***
    ***REMOVED*** auto_commit:: The commit command will be sent to Solr only if its value is set to true:
    ***REMOVED*** 
    ***REMOVED***                 class Author < ActiveRecord::Base
    ***REMOVED***                   acts_as_solr :auto_commit => false
    ***REMOVED***                 end
    ***REMOVED*** 
    def acts_as_solr(options={}, solr_options={})
      
      extend ClassMethods
      include InstanceMethods
      include CommonMethods
      include ParserMethods
      
      cattr_accessor :configuration
      cattr_accessor :solr_configuration
      
      self.configuration = { 
        :fields => nil,
        :additional_fields => nil,
        :exclude_fields => [],
        :auto_commit => true,
        :include => nil,
        :facets => nil,
        :boost => nil,
        :if => "true",
        :offline => false
      }  
      self.solr_configuration = {
        :type_field => "type_s",
        :primary_key_field => "pk_i",
        :default_boost => 1.0
      }
      
      configuration.update(options) if options.is_a?(Hash)
      solr_configuration.update(solr_options) if solr_options.is_a?(Hash)
      Deprecation.validate_index(configuration)
      
      configuration[:solr_fields] = {}
      configuration[:solr_includes] = {}
      
      after_save    :solr_save
      after_destroy :solr_destroy

      if configuration[:fields].respond_to?(:each)
        process_fields(configuration[:fields])
      else
        process_fields(self.new.attributes.keys.map { |k| k.to_sym })
        process_fields(configuration[:additional_fields])
      end

      if configuration[:include].respond_to?(:each)
        process_includes(configuration[:include])
      end
    end
    
    private
    def get_field_value(field)
      field_name, options = determine_field_name_and_options(field)
      configuration[:solr_fields][field_name] = options
      
      define_method("***REMOVED***{field_name}_for_solr".to_sym) do
        begin
          value = self[field_name] || self.instance_variable_get("@***REMOVED***{field_name.to_s}".to_sym) || self.send(field_name.to_sym)
          case options[:type] 
            ***REMOVED*** format dates properly; return nil for nil dates 
            when :date
              value ? (value.respond_to?(:utc) ? value.utc : value).strftime("%Y-%m-%dT%H:%M:%SZ") : nil 
            else value
          end
        rescue
          puts $!
          logger.debug "There was a problem getting the value for the field '***REMOVED***{field_name}': ***REMOVED***{$!}"
          value = ''
        end
      end
    end
    
    def process_fields(raw_field)
      if raw_field.respond_to?(:each)
        raw_field.each do |field|
          next if configuration[:exclude_fields].include?(field)
          get_field_value(field)
        end                
      end
    end
    
    def process_includes(includes)
      if includes.respond_to?(:each)
        includes.each do |assoc|
          field_name, options = determine_field_name_and_options(assoc)
          configuration[:solr_includes][field_name] = options
        end
      end
    end

    def determine_field_name_and_options(field)
      if field.is_a?(Hash)
        name = field.keys.first
        options = field.values.first
        if options.is_a?(Hash)
          [name, {:type => type_for_field(field)}.merge(options)]
        else
          [name, {:type => options}]
        end
      else
        [field, {:type => type_for_field(field)}]
      end
    end
    
    def type_for_field(field)
      if configuration[:facets] && configuration[:facets].include?(field)
        :facet
      elsif column = columns_hash[field.to_s]
        case column.type
        when :string then :text
        when :datetime then :date
        when :time then :date
        else column.type
        end
      else
        :text
      end
    end
  end
end