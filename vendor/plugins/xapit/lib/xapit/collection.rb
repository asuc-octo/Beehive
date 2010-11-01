module Xapit
  ***REMOVED*** This is the object which is returned when performing a search. It behaves like an array, so you do not need
  ***REMOVED*** to worry about fetching the results separately. Just loop through this collection.
  ***REMOVED*** 
  ***REMOVED*** The results are lazy loading, meaning it does not perform the query on the database until it has to.
  ***REMOVED*** This allows you to string queries onto one another.
  ***REMOVED***
  ***REMOVED***   Article.search("kite").search("sky") ***REMOVED*** only performs one query
  ***REMOVED***
  ***REMOVED*** This class is compatible with will_paginate; you can pass it to the will_paginate helper in the view.
  class Collection
    NON_DELEGATE_METHODS = %w(nil? send object_id class extend size paginate first last empty? respond_to?).to_set
    [].methods.each do |m|
      delegate m, :to => :results unless m =~ /^__/ || NON_DELEGATE_METHODS.include?(m.to_s)
    end
    delegate :query, :base_query, :base_query=, :extra_queries, :extra_queries=, :to => :@query_parser
    
    def self.search_similar(member, *args)
      collection = new(member.class, *args)
      indexer = SimpleIndexer.new(member.class.xapit_index_blueprint)
      terms = indexer.text_terms(member) + indexer.field_terms(member)
      query = collection.base_query.and_query(terms, :or).not_query("Q***REMOVED***{member.class}-***REMOVED***{member.id}")
      collection.base_query = query
      collection
    end
    
    def initialize(*args)
      @query_parser = Config.query_parser.new(*args)
    end
    
    ***REMOVED*** Returns an array of results. You should not need to call this directly because most methods are 
    ***REMOVED*** automatically delegated to this array.
    def results
      @results ||= fetch_results
    end
    
    ***REMOVED*** The number of total records found despite any pagination settings.
    def size
      @query_parser.query.count
    end
    alias_method :total_entries, :size ***REMOVED*** alias to total_entries to support will_paginate
    
    ***REMOVED*** Returns true if no results are found.
    def empty?
      @results ? @results.empty? : size.zero?
    end
    
    ***REMOVED*** The first record in the result set.
    def first
      fetch_results(:offset => 0, :limit => 1).first
    end
    
    ***REMOVED*** The last record in the result set.
    def last
      fetch_results(:offset => size-1, :limit => 1).last
    end
    
    ***REMOVED*** Perform another search on this one, inheriting all options already passed.
    ***REMOVED*** See Xapit::Membership for search options.
    ***REMOVED***
    ***REMOVED***   Article.search("kite").search("sky") ***REMOVED*** only performs one query
    ***REMOVED*** 
    def search(*args)
      options = args.extract_options!
      collection = Collection.new(@query_parser.member_class, args[0].to_s, @query_parser.options.merge(options))
      collection.base_query = @query_parser.query
      collection
    end
    
    ***REMOVED*** Chain another search returning all records matched by either this search or the previous search
    ***REMOVED*** Inherits all options passed in earlier search (such as :page and :order)
    ***REMOVED*** See Xapit::Membership for search options.
    ***REMOVED***
    ***REMOVED***   Article.search("kite").or_search(:conditions => { :priority => 1 })
    ***REMOVED*** 
    def or_search(*args)
      options = args.extract_options!
      collection = Collection.new(@query_parser.member_class, args[0].to_s, @query_parser.options.merge(options))
      collection.base_query = @query_parser.base_query
      collection.extra_queries = @query_parser.extra_queries
      collection.extra_queries << @query_parser.primary_query
      collection
    end
    
    ***REMOVED*** The page number we are currently on.
    def current_page
      @query_parser.current_page
    end
    
    ***REMOVED*** How many records to display on each page, defaults to 20. Sets with :per_page option when performing search.
    def per_page
      @query_parser.per_page
    end
    
    ***REMOVED*** The offset for the current page
    def offset
      @query_parser.offset
    end
    
    ***REMOVED*** Total number of pages with found results.
    def total_pages
      (size / per_page.to_f).ceil
    end
    
    ***REMOVED*** The previous page number. Returns nil if on first page.
    def previous_page
      current_page > 1 ? (current_page - 1) : nil
    end
    
    ***REMOVED*** The next page number. Returns nil if on last page.
    def next_page
      current_page < total_pages ? (current_page + 1): nil
    end
    
    ***REMOVED*** Xapit::Facet objects matching this search query. See class for details.
    def facets
      all_facets.select do |facet|
        facet.options.size > 0
      end
    end
    
    ***REMOVED*** Xapit::FacetOption objects which are currently applied to search (through :facets option). Use this to
    ***REMOVED*** display the facets which are currently applied.
    ***REMOVED***
    ***REMOVED***   <% for option in @articles.applied_facet_options %>
    ***REMOVED***     <%=h option.name %>
    ***REMOVED***     <%= link_to "remove", :overwrite_params => { :facets => option } %>
    ***REMOVED***   <% end %>
    ***REMOVED***
    ***REMOVED*** If you set :breadcrumb_facets option to true in Config***REMOVED***setup the link will drop leftover facets
    ***REMOVED*** instead of removing the current one. This makes it easy to add a breadcrumb style interface.
    ***REMOVED***
    ***REMOVED***   Xapit.setup(:breadcrumb_facets => true)
    ***REMOVED***   <% for option in @articles.applied_facet_options %>
    ***REMOVED***     <%= link_to h(option.name), :overwrite_params => { :facets => option } %> &gt;
    ***REMOVED***   <% end %>
    ***REMOVED***
    def applied_facet_options
      @query_parser.facet_identifiers.map do |identifier|
        option = FacetOption.find(identifier)
        option.existing_facet_identifiers = @query_parser.facet_identifiers
        option
      end
    end
    
    ***REMOVED*** Includes a suggested variation of a term which will get many more results. Returns nil if no suggestion.
    ***REMOVED*** 
    ***REMOVED***   <% if @articles.spelling_suggestion %>
    ***REMOVED***     Did you mean <%= link_to h(@articles.spelling_suggestion), :overwrite_params => { :keywords => @articles.spelling_suggestion } %>?
    ***REMOVED***   <% end %>
    ***REMOVED*** 
    def spelling_suggestion
      @query_parser.spelling_suggestion
    end
    
    ***REMOVED*** All Xapit::Facet objects, even if they do not include options.
    ***REMOVED*** Usually you'll want to call Collection***REMOVED***facets
    def all_facets
      @query_parser.member_class.xapit_index_blueprint.facets.map do |facet_blueprint|
        Facet.new(facet_blueprint, @query_parser.query, @query_parser.facet_identifiers)
      end
    end
    
    private
    
    ***REMOVED*** TODO this could use some refactoring
    ***REMOVED*** See issue ***REMOVED***11 for why this is so complex.
    def fetch_results(options = {})
      matches = @query_parser.matchset(options).matches
      records_by_class = {}
      matches.each do |match|
        class_name, id = match.document.data.split('-')
        records_by_class[class_name] ||= []
        records_by_class[class_name] << id
      end
      records_by_class.each do |class_name, ids|
        records_by_class[class_name] = class_name.constantize.xapit_adapter.find_multiple(ids)
      end
      matches.map do |match|
        class_name, id = match.document.data.split('-')
        member = records_by_class[class_name].detect { |m| m.id == id.to_i }
        member.xapit_relevance = match.percent
        member
      end
    end
  end
end
