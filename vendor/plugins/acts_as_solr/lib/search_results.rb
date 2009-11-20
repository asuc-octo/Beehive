module ActsAsSolr ***REMOVED***:nodoc:
  
  ***REMOVED*** TODO: Possibly looking into hooking it up with Solr::Response::Standard
  ***REMOVED*** 
  ***REMOVED*** Class that returns the search results with four methods.
  ***REMOVED*** 
  ***REMOVED***   books = Book.find_by_solr 'ruby'
  ***REMOVED*** 
  ***REMOVED*** the above will return a SearchResults class with 4 methods:
  ***REMOVED*** 
  ***REMOVED*** docs|results|records: will return an array of records found
  ***REMOVED*** 
  ***REMOVED***   books.records.empty?
  ***REMOVED***   => false
  ***REMOVED*** 
  ***REMOVED*** total|num_found|total_hits: will return the total number of records found
  ***REMOVED*** 
  ***REMOVED***   books.total
  ***REMOVED***   => 2
  ***REMOVED*** 
  ***REMOVED*** facets: will return the facets when doing a faceted search
  ***REMOVED*** 
  ***REMOVED*** max_score|highest_score: returns the highest score found
  ***REMOVED*** 
  ***REMOVED***   books.max_score
  ***REMOVED***   => 1.3213213
  ***REMOVED*** 
  ***REMOVED*** 
  class SearchResults
    def initialize(solr_data={})
      @solr_data = solr_data
    end
    
    ***REMOVED*** Returns an array with the instances. This method
    ***REMOVED*** is also aliased as docs and records
    def results
      @solr_data[:docs]
    end
    
    ***REMOVED*** Returns the total records found. This method is
    ***REMOVED*** also aliased as num_found and total_hits
    def total
      @solr_data[:total]
    end
    
    ***REMOVED*** Returns the facets when doing a faceted search
    def facets
      @solr_data[:facets]
    end
    
    ***REMOVED*** Returns the highest score found. This method is
    ***REMOVED*** also aliased as highest_score
    def max_score
      @solr_data[:max_score]
    end
    
    def query_time
      @solr_data[:query_time]
    end
    
    alias docs results
    alias records results
    alias num_found total
    alias total_hits total
    alias highest_score max_score
  end
  
end