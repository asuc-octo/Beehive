require File.dirname(__FILE__) + '/common_methods'
require File.dirname(__FILE__) + '/parser_methods'

module ActsAsSolr ***REMOVED***:nodoc:

  module ClassMethods
    include CommonMethods
    include ParserMethods
    
    ***REMOVED*** Finds instances of a model. Terms are ANDed by default, can be overwritten 
    ***REMOVED*** by using OR between terms
    ***REMOVED*** 
    ***REMOVED*** Here's a sample (untested) code for your controller:
    ***REMOVED*** 
    ***REMOVED***  def search
    ***REMOVED***    results = Book.find_by_solr params[:query]
    ***REMOVED***  end
    ***REMOVED*** 
    ***REMOVED*** You can also search for specific fields by searching for 'field:value'
    ***REMOVED*** 
    ***REMOVED*** ====options:
    ***REMOVED*** offset:: - The first document to be retrieved (offset)
    ***REMOVED*** limit:: - The number of rows per page
    ***REMOVED*** order:: - Orders (sort by) the result set using a given criteria:
    ***REMOVED***
    ***REMOVED***             Book.find_by_solr 'ruby', :order => 'description asc'
    ***REMOVED*** 
    ***REMOVED*** field_types:: This option is deprecated and will be obsolete by version 1.0.
    ***REMOVED***               There's no need to specify the :field_types anymore when doing a 
    ***REMOVED***               search in a model that specifies a field type for a field. The field 
    ***REMOVED***               types are automatically traced back when they're included.
    ***REMOVED*** 
    ***REMOVED***                 class Electronic < ActiveRecord::Base
    ***REMOVED***                   acts_as_solr :fields => [{:price => :range_float}]
    ***REMOVED***                 end
    ***REMOVED*** 
    ***REMOVED*** facets:: This option argument accepts the following arguments:
    ***REMOVED***          fields:: The fields to be included in the faceted search (Solr's facet.field)
    ***REMOVED***          query:: The queries to be included in the faceted search (Solr's facet.query)
    ***REMOVED***          zeros:: Display facets with count of zero. (true|false)
    ***REMOVED***          sort:: Sorts the faceted resuls by highest to lowest count. (true|false)
    ***REMOVED***          browse:: This is where the 'drill-down' of the facets work. Accepts an array of
    ***REMOVED***                   fields in the format "facet_field:term"
    ***REMOVED***          mincount:: Replacement for zeros (it has been deprecated in Solr). Specifies the
    ***REMOVED***                     minimum count necessary for a facet field to be returned. (Solr's
    ***REMOVED***                     facet.mincount) Overrides :zeros if it is specified. Default is 0.
    ***REMOVED***
    ***REMOVED***          dates:: Run date faceted queries using the following arguments:
    ***REMOVED***            fields:: The fields to be included in the faceted date search (Solr's facet.date).
    ***REMOVED***                     It may be either a String/Symbol or Hash. If it's a hash the options are the
    ***REMOVED***                     same as date_facets minus the fields option (i.e., :start:, :end, :gap, :other,
    ***REMOVED***                     :between). These options if provided will override the base options.
    ***REMOVED***                     (Solr's f.<field_name>.date.<key>=<value>).
    ***REMOVED***            start:: The lower bound for the first date range for all Date Faceting. Required if
    ***REMOVED***                    :fields is present
    ***REMOVED***            end:: The upper bound for the last date range for all Date Faceting. Required if
    ***REMOVED***                  :fields is prsent
    ***REMOVED***            gap:: The size of each date range expressed as an interval to be added to the lower
    ***REMOVED***                  bound using the DateMathParser syntax.  Required if :fields is prsent
    ***REMOVED***            hardend:: A Boolean parameter instructing Solr what do do in the event that
    ***REMOVED***                      facet.date.gap does not divide evenly between facet.date.start and facet.date.end.
    ***REMOVED***            other:: This param indicates that in addition to the counts for each date range
    ***REMOVED***                    constraint between facet.date.start and facet.date.end, other counds should be
    ***REMOVED***                    calculated. May specify more then one in an Array. The possible options are:
    ***REMOVED***              before:: - all records with lower bound less than start
    ***REMOVED***              after:: - all records with upper bound greater than end
    ***REMOVED***              between:: - all records with field values between start and end
    ***REMOVED***              none:: - compute no other bounds (useful in per field assignment)
    ***REMOVED***              all:: - shortcut for before, after, and between
    ***REMOVED***            filter:: Similar to :query option provided by :facets, in that accepts an array of
    ***REMOVED***                     of date queries to limit results. Can not be used as a part of a :field hash.
    ***REMOVED***                     This is the only option that can be used if :fields is not present.
    ***REMOVED*** 
    ***REMOVED*** Example:
    ***REMOVED*** 
    ***REMOVED***   Electronic.find_by_solr "memory", :facets => {:zeros => false, :sort => true,
    ***REMOVED***                                                 :query => ["price:[* TO 200]",
    ***REMOVED***                                                            "price:[200 TO 500]",
    ***REMOVED***                                                            "price:[500 TO *]"],
    ***REMOVED***                                                 :fields => [:category, :manufacturer],
    ***REMOVED***                                                 :browse => ["category:Memory","manufacturer:Someone"]}
    ***REMOVED*** 
    ***REMOVED***
    ***REMOVED*** Examples of date faceting:
    ***REMOVED***
    ***REMOVED***  basic:
    ***REMOVED***    Electronic.find_by_solr "memory", :facets => {:dates => {:fields => [:updated_at, :created_at],
    ***REMOVED***      :start => 'NOW-10YEARS/DAY', :end => 'NOW/DAY', :gap => '+2YEARS', :other => :before}}
    ***REMOVED***
    ***REMOVED***  advanced:
    ***REMOVED***    Electronic.find_by_solr "memory", :facets => {:dates => {:fields => [:updated_at,
    ***REMOVED***    {:created_at => {:start => 'NOW-20YEARS/DAY', :end => 'NOW-10YEARS/DAY', :other => [:before, :after]}
    ***REMOVED***    }], :start => 'NOW-10YEARS/DAY', :end => 'NOW/DAY', :other => :before, :filter =>
    ***REMOVED***    ["created_at:[NOW-10YEARS/DAY TO NOW/DAY]", "updated_at:[NOW-1YEAR/DAY TO NOW/DAY]"]}}
    ***REMOVED***
    ***REMOVED***  filter only:
    ***REMOVED***    Electronic.find_by_solr "memory", :facets => {:dates => {:filter => "updated_at:[NOW-1YEAR/DAY TO NOW/DAY]"}}
    ***REMOVED***
    ***REMOVED***
    ***REMOVED***
    ***REMOVED*** scores:: If set to true this will return the score as a 'solr_score' attribute
    ***REMOVED***          for each one of the instances found. Does not currently work with find_id_by_solr
    ***REMOVED*** 
    ***REMOVED***            books = Book.find_by_solr 'ruby OR splinter', :scores => true
    ***REMOVED***            books.records.first.solr_score
    ***REMOVED***            => 1.21321397
    ***REMOVED***            books.records.last.solr_score
    ***REMOVED***            => 0.12321548
    ***REMOVED*** 
    ***REMOVED*** lazy:: If set to true the search will return objects that will touch the database when you ask for one
    ***REMOVED***        of their attributes for the first time. Useful when you're using fragment caching based solely on
    ***REMOVED***        types and ids.
    ***REMOVED***
    def find_by_solr(query, options={})
      data = parse_query(query, options)
      return parse_results(data, options) if data
    end
    
    ***REMOVED*** Finds instances of a model and returns an array with the ids:
    ***REMOVED***  Book.find_id_by_solr "rails" => [1,4,7]
    ***REMOVED*** The options accepted are the same as find_by_solr
    ***REMOVED*** 
    def find_id_by_solr(query, options={})
      data = parse_query(query, options)
      return parse_results(data, {:format => :ids}) if data
    end
    
    ***REMOVED*** This method can be used to execute a search across multiple models:
    ***REMOVED***   Book.multi_solr_search "Napoleon OR Tom", :models => [Movie]
    ***REMOVED*** 
    ***REMOVED*** ====options:
    ***REMOVED*** Accepts the same options as find_by_solr plus:
    ***REMOVED*** models:: The additional models you'd like to include in the search
    ***REMOVED*** results_format:: Specify the format of the results found
    ***REMOVED***                  :objects :: Will return an array with the results being objects (default). Example:
    ***REMOVED***                               Book.multi_solr_search "Napoleon OR Tom", :models => [Movie], :results_format => :objects
    ***REMOVED***                  :ids :: Will return an array with the ids of each entry found. Example:
    ***REMOVED***                           Book.multi_solr_search "Napoleon OR Tom", :models => [Movie], :results_format => :ids
    ***REMOVED***                           => [{"id" => "Movie:1"},{"id" => Book:1}]
    ***REMOVED***                          Where the value of each array is as Model:instance_id
    ***REMOVED*** scores:: If set to true this will return the score as a 'solr_score' attribute
    ***REMOVED***          for each one of the instances found. Does not currently work with find_id_by_solr
    ***REMOVED*** 
    ***REMOVED***            books = Book.multi_solr_search 'ruby OR splinter', :scores => true
    ***REMOVED***            books.records.first.solr_score
    ***REMOVED***            => 1.21321397
    ***REMOVED***            books.records.last.solr_score
    ***REMOVED***            => 0.12321548
    ***REMOVED*** 
    def multi_solr_search(query, options = {})
      models = multi_model_suffix(options)
      options.update(:results_format => :objects) unless options[:results_format]
      data = parse_query(query, options, models)
      
      if data.nil? or data.total_hits == 0
        return SearchResults.new(:docs => [], :total => 0)
      end

      result = find_multi_search_objects(data, options)
      if options[:scores] and options[:results_format] == :objects
        add_scores(result, data) 
      end
      SearchResults.new :docs => result, :total => data.total_hits
    end

    def find_multi_search_objects(data, options)
      result = []
      if options[:results_format] == :objects
        data.hits.each do |doc| 
          k = doc.fetch('id').first.to_s.split(':')
          result << k[0].constantize.find_by_id(k[1])
        end
      elsif options[:results_format] == :ids
        data.hits.each{|doc| result << {"id" => doc.values.pop.to_s}}
      end
      result
    end
    
    def multi_model_suffix(options)
      models = "AND (***REMOVED***{solr_configuration[:type_field]}:***REMOVED***{self.name}"
      models << " OR " + options[:models].collect {|m| "***REMOVED***{solr_configuration[:type_field]}:" + m.to_s}.join(" OR ") if options[:models].is_a?(Array)
      models << ")"
    end
    
    ***REMOVED*** returns the total number of documents found in the query specified:
    ***REMOVED***  Book.count_by_solr 'rails' => 3
    ***REMOVED*** 
    def count_by_solr(query, options = {})        
      data = parse_query(query, options)
      data.total_hits
    end
            
    ***REMOVED*** It's used to rebuild the Solr index for a specific model. 
    ***REMOVED***  Book.rebuild_solr_index
    ***REMOVED*** 
    ***REMOVED*** If batch_size is greater than 0, adds will be done in batches.
    ***REMOVED*** NOTE: If using sqlserver, be sure to use a finder with an explicit order.
    ***REMOVED*** Non-edge versions of rails do not handle pagination correctly for sqlserver
    ***REMOVED*** without an order clause.
    ***REMOVED*** 
    ***REMOVED*** If a finder block is given, it will be called to retrieve the items to index.
    ***REMOVED*** This can be very useful for things such as updating based on conditions or
    ***REMOVED*** using eager loading for indexed associations.
    def rebuild_solr_index(batch_size=0, &finder)
      finder ||= lambda { |ar, options| ar.find(:all, options.merge({:order => self.primary_key})) }
      start_time = Time.now

      if batch_size > 0
        items_processed = 0
        limit = batch_size
        offset = 0
        begin
          iteration_start = Time.now
          items = finder.call(self, {:limit => limit, :offset => offset})
          add_batch = items.collect { |content| content.to_solr_doc }
    
          if items.size > 0
            solr_add add_batch
            solr_commit
          end
    
          items_processed += items.size
          last_id = items.last.id if items.last
          time_so_far = Time.now - start_time
          iteration_time = Time.now - iteration_start         
          logger.info "***REMOVED***{Process.pid}: ***REMOVED***{items_processed} items for ***REMOVED***{self.name} have been batch added to index in ***REMOVED***{'%.3f' % time_so_far}s at ***REMOVED***{'%.3f' % (items_processed / time_so_far)} items/sec (***REMOVED***{'%.3f' % (items.size / iteration_time)} items/sec for the last batch). Last id: ***REMOVED***{last_id}"
          offset += items.size
        end while items.nil? || items.size > 0
      else
        items = finder.call(self, {})
        items.each { |content| content.solr_save }
        items_processed = items.size
      end
      solr_optimize
      logger.info items_processed > 0 ? "Index for ***REMOVED***{self.name} has been rebuilt" : "Nothing to index for ***REMOVED***{self.name}"
    end
  end
  
end