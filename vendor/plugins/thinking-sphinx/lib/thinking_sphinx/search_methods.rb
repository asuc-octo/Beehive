module ThinkingSphinx
  module SearchMethods
    def self.included(base)
      base.class_eval do
        extend ThinkingSphinx::SearchMethods::ClassMethods
      end
    end
    
    module ClassMethods
      def search_context
        ***REMOVED*** Comparing to name string to avoid class inheritance complications
        case self.class.name
        when 'Class'
          self
        else
          nil
        end
      end
      
      ***REMOVED*** Searches through the Sphinx indexes for relevant matches. There's
      ***REMOVED*** various ways to search, sort, group and filter - which are covered
      ***REMOVED*** below.
      ***REMOVED***
      ***REMOVED*** Also, if you have WillPaginate installed, the search method can be used
      ***REMOVED*** just like paginate. The same parameters - :page and :per_page - work as
      ***REMOVED*** expected, and the returned result set can be used by the will_paginate
      ***REMOVED*** helper.
      ***REMOVED*** 
      ***REMOVED*** == Basic Searching
      ***REMOVED***
      ***REMOVED*** The simplest way of searching is straight text.
      ***REMOVED*** 
      ***REMOVED***   ThinkingSphinx.search "pat"
      ***REMOVED***   ThinkingSphinx.search "google"
      ***REMOVED***   User.search "pat", :page => (params[:page] || 1)
      ***REMOVED***   Article.search "relevant news issue of the day"
      ***REMOVED***
      ***REMOVED*** If you specify :include, like in an ***REMOVED***find call, this will be respected
      ***REMOVED*** when loading the relevant models from the search results.
      ***REMOVED*** 
      ***REMOVED***   User.search "pat", :include => :posts
      ***REMOVED***
      ***REMOVED*** == Match Modes
      ***REMOVED***
      ***REMOVED*** Sphinx supports 5 different matching modes. By default Thinking Sphinx
      ***REMOVED*** uses :all, which unsurprisingly requires all the supplied search terms
      ***REMOVED*** to match a result.
      ***REMOVED***
      ***REMOVED*** Alternative modes include:
      ***REMOVED***
      ***REMOVED***   User.search "pat allan", :match_mode => :any
      ***REMOVED***   User.search "pat allan", :match_mode => :phrase
      ***REMOVED***   User.search "pat | allan", :match_mode => :boolean
      ***REMOVED***   User.search "@name pat | @username pat", :match_mode => :extended
      ***REMOVED***
      ***REMOVED*** Any will find results with any of the search terms. Phrase treats the
      ***REMOVED*** search terms a single phrase instead of individual words. Boolean and 
      ***REMOVED*** extended allow for more complex query syntax, refer to the sphinx
      ***REMOVED*** documentation for further details.
      ***REMOVED***
      ***REMOVED*** == Weighting
      ***REMOVED***
      ***REMOVED*** Sphinx has support for weighting, where matches in one field can be
      ***REMOVED*** considered more important than in another. Weights are integers, with 1
      ***REMOVED*** as the default. They can be set per-search like this:
      ***REMOVED***
      ***REMOVED***   User.search "pat allan", :field_weights => { :alias => 4, :aka => 2 }
      ***REMOVED***
      ***REMOVED*** If you're searching multiple models, you can set per-index weights:
      ***REMOVED***
      ***REMOVED***   ThinkingSphinx.search "pat", :index_weights => { User => 10 }
      ***REMOVED***
      ***REMOVED*** See http://sphinxsearch.com/doc.html***REMOVED***weighting for further details.
      ***REMOVED***
      ***REMOVED*** == Searching by Fields
      ***REMOVED*** 
      ***REMOVED*** If you want to step it up a level, you can limit your search terms to
      ***REMOVED*** specific fields:
      ***REMOVED*** 
      ***REMOVED***   User.search :conditions => {:name => "pat"}
      ***REMOVED***
      ***REMOVED*** This uses Sphinx's extended match mode, unless you specify a different
      ***REMOVED*** match mode explicitly (but then this way of searching won't work). Also
      ***REMOVED*** note that you don't need to put in a search string.
      ***REMOVED***
      ***REMOVED*** == Searching by Attributes
      ***REMOVED***
      ***REMOVED*** Also known as filters, you can limit your searches to documents that
      ***REMOVED*** have specific values for their attributes. There are three ways to do
      ***REMOVED*** this. The first two techniques work in all scenarios - using the :with
      ***REMOVED*** or :with_all options.
      ***REMOVED***
      ***REMOVED***   ThinkingSphinx.search :with => {:tag_ids => 10}
      ***REMOVED***   ThinkingSphinx.search :with => {:tag_ids => [10,12]}
      ***REMOVED***   ThinkingSphinx.search :with_all => {:tag_ids => [10,12]}
      ***REMOVED***
      ***REMOVED*** The first :with search will match records with a tag_id attribute of 10.
      ***REMOVED*** The second :with will match records with a tag_id attribute of 10 OR 12.
      ***REMOVED*** If you need to find records that are tagged with ids 10 AND 12, you
      ***REMOVED*** will need to use the :with_all search parameter. This is particuarly
      ***REMOVED*** useful in conjunction with Multi Value Attributes (MVAs).
      ***REMOVED***
      ***REMOVED*** The third filtering technique is only viable if you're searching with a
      ***REMOVED*** specific model (not multi-model searching). With a single model,
      ***REMOVED*** Thinking Sphinx can figure out what attributes and fields are available,
      ***REMOVED*** so you can put it all in the :conditions hash, and it will sort it out.
      ***REMOVED*** 
      ***REMOVED***   Node.search :conditions => {:parent_id => 10}
      ***REMOVED*** 
      ***REMOVED*** Filters can be single values, arrays of values, or ranges.
      ***REMOVED*** 
      ***REMOVED***   Article.search "East Timor", :conditions => {:rating => 3..5}
      ***REMOVED***
      ***REMOVED*** == Excluding by Attributes
      ***REMOVED***
      ***REMOVED*** Sphinx also supports negative filtering - where the filters are of
      ***REMOVED*** attribute values to exclude. This is done with the :without option:
      ***REMOVED***
      ***REMOVED***   User.search :without => {:role_id => 1}
      ***REMOVED***
      ***REMOVED*** == Excluding by Primary Key
      ***REMOVED***
      ***REMOVED*** There is a shortcut to exclude records by their ActiveRecord primary
      ***REMOVED*** key:
      ***REMOVED***
      ***REMOVED***   User.search :without_ids => 1
      ***REMOVED***
      ***REMOVED*** Pass an array or a single value.
      ***REMOVED***
      ***REMOVED*** The primary key must be an integer as a negative filter is used. Note
      ***REMOVED*** that for multi-model search, an id may occur in more than one model.
      ***REMOVED***
      ***REMOVED*** == Infix (Star) Searching
      ***REMOVED*** 
      ***REMOVED*** Enable infix searching by something like this in config/sphinx.yml:
      ***REMOVED***
      ***REMOVED***   ***REMOVED***
      ***REMOVED***     enable_star: 1
      ***REMOVED***     min_infix_len: 2
      ***REMOVED***
      ***REMOVED*** Note that this will make indexing take longer.
      ***REMOVED***
      ***REMOVED*** With those settings (and after reindexing), wildcard asterisks can be
      ***REMOVED*** used in queries:
      ***REMOVED***
      ***REMOVED***   Location.search "*elbourn*"
      ***REMOVED***
      ***REMOVED*** To automatically add asterisks around every token (but not operators),
      ***REMOVED*** pass the :star option:
      ***REMOVED***
      ***REMOVED***   Location.search "elbourn -ustrali", :star => true,
      ***REMOVED***     :match_mode => :boolean
      ***REMOVED***
      ***REMOVED*** This would become "*elbourn* -*ustrali*". The :star option only adds the
      ***REMOVED*** asterisks. You need to make the config/sphinx.yml changes yourself.
      ***REMOVED***
      ***REMOVED*** By default, the tokens are assumed to match the regular expression
      ***REMOVED*** /\w\+/u\+. If you've modified the charset_table, pass another regular
      ***REMOVED*** expression, e.g.
      ***REMOVED***
      ***REMOVED***   User.search("oo@bar.c", :star => /[\w@.]+/u)
      ***REMOVED***
      ***REMOVED*** to search for "*oo@bar.c*" and not "*oo*@*bar*.*c*".
      ***REMOVED***
      ***REMOVED*** == Sorting
      ***REMOVED***
      ***REMOVED*** Sphinx can only sort by attributes, so generally you will need to avoid
      ***REMOVED*** using field names in your :order option. However, if you're searching
      ***REMOVED*** on a single model, and have specified some fields as sortable, you can
      ***REMOVED*** use those field names and Thinking Sphinx will interpret accordingly.
      ***REMOVED*** Remember: this will only happen for single-model searches, and only
      ***REMOVED*** through the :order option.
      ***REMOVED***
      ***REMOVED***   Location.search "Melbourne", :order => :state
      ***REMOVED***   User.search :conditions => {:role_id => 2}, :order => "name ASC"
      ***REMOVED***
      ***REMOVED*** Keep in mind that if you use a string, you *must* specify the direction
      ***REMOVED*** (ASC or DESC) else Sphinx won't return any results. If you use a symbol
      ***REMOVED*** then Thinking Sphinx assumes ASC, but if you wish to state otherwise,
      ***REMOVED*** use the :sort_mode option:
      ***REMOVED***
      ***REMOVED***   Location.search "Melbourne", :order => :state, :sort_mode => :desc
      ***REMOVED***
      ***REMOVED*** Of course, there are other sort modes - check out the Sphinx
      ***REMOVED*** documentation[http://sphinxsearch.com/doc.html] for that level of
      ***REMOVED*** detail though.
      ***REMOVED***
      ***REMOVED*** If desired, you can sort by a column in your model instead of a sphinx
      ***REMOVED*** field or attribute. This sort only applies to the current page, so is
      ***REMOVED*** most useful when performing a search with a single page of results.
      ***REMOVED***
      ***REMOVED***   User.search("pat", :sql_order => "name")
      ***REMOVED***
      ***REMOVED*** == Grouping
      ***REMOVED*** 
      ***REMOVED*** For this you can use the group_by, group_clause and group_function
      ***REMOVED*** options - which are all directly linked to Sphinx's expectations. No
      ***REMOVED*** magic from Thinking Sphinx. It can get a little tricky, so make sure
      ***REMOVED*** you read all the relevant
      ***REMOVED*** documentation[http://sphinxsearch.com/doc.html***REMOVED***clustering] first.
      ***REMOVED*** 
      ***REMOVED*** Grouping is done via three parameters within the options hash
      ***REMOVED*** * <tt>:group_function</tt> determines the way grouping is done
      ***REMOVED*** * <tt>:group_by</tt> determines the field which is used for grouping
      ***REMOVED*** * <tt>:group_clause</tt> determines the sorting order 
      ***REMOVED***
      ***REMOVED*** As a convenience, you can also use
      ***REMOVED*** * <tt>:group</tt>
      ***REMOVED*** which sets :group_by and defaults to :group_function of :attr
      ***REMOVED*** 
      ***REMOVED*** === group_function
      ***REMOVED***  
      ***REMOVED*** Valid values for :group_function are
      ***REMOVED*** * <tt>:day</tt>, <tt>:week</tt>, <tt>:month</tt>, <tt>:year</tt> - Grouping is done by the respective timeframes. 
      ***REMOVED*** * <tt>:attr</tt>, <tt>:attrpair</tt> - Grouping is done by the specified attributes(s)
      ***REMOVED*** 
      ***REMOVED*** === group_by
      ***REMOVED***
      ***REMOVED*** This parameter denotes the field by which grouping is done. Note that
      ***REMOVED*** the specified field must be a sphinx attribute or index.
      ***REMOVED***
      ***REMOVED*** === group_clause
      ***REMOVED***
      ***REMOVED*** This determines the sorting order of the groups. In a grouping search,
      ***REMOVED*** the matches within a group will sorted by the <tt>:sort_mode</tt> and
      ***REMOVED*** <tt>:order</tt> parameters. The group matches themselves however, will
      ***REMOVED*** be sorted by <tt>:group_clause</tt>. 
      ***REMOVED*** 
      ***REMOVED*** The syntax for this is the same as an order parameter in extended sort
      ***REMOVED*** mode. Namely, you can specify an SQL-like sort expression with up to 5
      ***REMOVED*** attributes (including internal attributes), eg: "@relevance DESC, price
      ***REMOVED*** ASC, @id DESC"
      ***REMOVED***
      ***REMOVED*** === Grouping by timestamp
      ***REMOVED*** 
      ***REMOVED*** Timestamp grouping groups off items by the day, week, month or year of 
      ***REMOVED*** the attribute given. In order to do this you need to define a timestamp
      ***REMOVED*** attribute, which pretty much looks like the standard defintion for any
      ***REMOVED*** attribute.
      ***REMOVED***
      ***REMOVED***   define_index do
      ***REMOVED***     ***REMOVED***
      ***REMOVED***     ***REMOVED*** All your other stuff
      ***REMOVED***     ***REMOVED***
      ***REMOVED***     has :created_at
      ***REMOVED***   end
      ***REMOVED***
      ***REMOVED*** When you need to fire off your search, it'll go something to the tune of
      ***REMOVED***   
      ***REMOVED***   Fruit.search "apricot", :group_function => :day,
      ***REMOVED***     :group_by => 'created_at'
      ***REMOVED***
      ***REMOVED*** The <tt>@groupby</tt> special attribute will contain the date for that
      ***REMOVED*** group. Depending on the <tt>:group_function</tt> parameter, the date
      ***REMOVED*** format will be:
      ***REMOVED***
      ***REMOVED*** * <tt>:day</tt> - YYYYMMDD
      ***REMOVED*** * <tt>:week</tt> - YYYYNNN (NNN is the first day of the week in question, 
      ***REMOVED***   counting from the start of the year )
      ***REMOVED*** * <tt>:month</tt> - YYYYMM
      ***REMOVED*** * <tt>:year</tt> - YYYY
      ***REMOVED***
      ***REMOVED*** === Grouping by attribute
      ***REMOVED***
      ***REMOVED*** The syntax is the same as grouping by timestamp, except for the fact
      ***REMOVED*** that the <tt>:group_function</tt> parameter is changed.
      ***REMOVED***
      ***REMOVED***   Fruit.search "apricot", :group_function => :attr, :group_by => 'size'
      ***REMOVED*** 
      ***REMOVED*** == Geo/Location Searching
      ***REMOVED***
      ***REMOVED*** Sphinx - and therefore Thinking Sphinx - has the facility to search
      ***REMOVED*** around a geographical point, using a given latitude and longitude. To
      ***REMOVED*** take advantage of this, you will need to have both of those values in
      ***REMOVED*** attributes. To search with that point, you can then use one of the
      ***REMOVED*** following syntax examples:
      ***REMOVED*** 
      ***REMOVED***   Address.search "Melbourne", :geo => [1.4, -2.217],
      ***REMOVED***     :order => "@geodist asc"
      ***REMOVED***   Address.search "Australia", :geo => [-0.55, 3.108],
      ***REMOVED***     :order => "@geodist asc" :latitude_attr => "latit",
      ***REMOVED***     :longitude_attr => "longit"
      ***REMOVED*** 
      ***REMOVED*** The first example applies when your latitude and longitude attributes
      ***REMOVED*** are named any of lat, latitude, lon, long or longitude. If that's not
      ***REMOVED*** the case, you will need to explicitly state them in your search, _or_
      ***REMOVED*** you can do so in your model:
      ***REMOVED***
      ***REMOVED***   define_index do
      ***REMOVED***     has :latit  ***REMOVED*** Float column, stored in radians
      ***REMOVED***     has :longit ***REMOVED*** Float column, stored in radians
      ***REMOVED***     
      ***REMOVED***     set_property :latitude_attr   => "latit"
      ***REMOVED***     set_property :longitude_attr  => "longit"
      ***REMOVED***   end
      ***REMOVED*** 
      ***REMOVED*** Now, geo-location searching really only has an affect if you have a
      ***REMOVED*** filter, sort or grouping clause related to it - otherwise it's just a
      ***REMOVED*** normal search, and _will not_ return a distance value otherwise. To
      ***REMOVED*** make use of the positioning difference, use the special attribute
      ***REMOVED*** "@geodist" in any of your filters or sorting or grouping clauses.
      ***REMOVED*** 
      ***REMOVED*** And don't forget - both the latitude and longitude you use in your
      ***REMOVED*** search, and the values in your indexes, need to be stored as a float in
      ***REMOVED*** radians, _not_ degrees. Keep in mind that if you do this conversion in 
      ***REMOVED*** SQL you will need to explicitly declare a column type of :float.
      ***REMOVED***
      ***REMOVED***   define_index do
      ***REMOVED***     has 'RADIANS(lat)', :as => :lat,  :type => :float
      ***REMOVED***     ***REMOVED*** ...
      ***REMOVED***   end
      ***REMOVED*** 
      ***REMOVED*** Once you've got your results set, you can access the distances as
      ***REMOVED*** follows:
      ***REMOVED*** 
      ***REMOVED***   @results.each_with_geodist do |result, distance|
      ***REMOVED***     ***REMOVED*** ...
      ***REMOVED***   end
      ***REMOVED*** 
      ***REMOVED*** The distance value is returned as a float, representing the distance in
      ***REMOVED*** metres.
      ***REMOVED*** 
      ***REMOVED*** == Filtering by custom attributes
      ***REMOVED***
      ***REMOVED*** Do note that this applies only to sphinx 0.9.9
      ***REMOVED*** 
      ***REMOVED*** Should you find yourself in desperate need of a filter that involves
      ***REMOVED*** selecting either one of multiple conditions, one solution could be
      ***REMOVED*** provided by the :sphinx_select option within the search. 
      ***REMOVED*** This handles which fields are selected by sphinx from its store.
      ***REMOVED***
      ***REMOVED*** The default value is "*", and you can add custom fields using syntax
      ***REMOVED*** similar to sql:
      ***REMOVED***
      ***REMOVED***   Flower.search "foo",
      ***REMOVED***     :sphinx_select => "*, petals < 1 or color = 2 as grass"
      ***REMOVED***
      ***REMOVED*** This will add the 'grass' attribute, which will now be usable in your
      ***REMOVED*** filters.
      ***REMOVED***   
      ***REMOVED*** == Handling a Stale Index
      ***REMOVED***
      ***REMOVED*** Especially if you don't use delta indexing, you risk having records in
      ***REMOVED*** the Sphinx index that are no longer in the database. By default, those 
      ***REMOVED*** will simply come back as nils:
      ***REMOVED***
      ***REMOVED***   >> pat_user.delete
      ***REMOVED***   >> User.search("pat")
      ***REMOVED***   Sphinx Result: [1,2]
      ***REMOVED***   => [nil, <***REMOVED***User id: 2>]
      ***REMOVED***
      ***REMOVED*** (If you search across multiple models, you'll get
      ***REMOVED*** ActiveRecord::RecordNotFound.)
      ***REMOVED***
      ***REMOVED*** You can simply Array***REMOVED***compact these results or handle the nils in some 
      ***REMOVED*** other way, but Sphinx will still report two results, and the missing
      ***REMOVED*** records may upset your layout.
      ***REMOVED***
      ***REMOVED*** If you pass :retry_stale => true to a single-model search, missing
      ***REMOVED*** records will cause Thinking Sphinx to retry the query but excluding
      ***REMOVED*** those records. Since search is paginated, the new search could
      ***REMOVED*** potentially include missing records as well, so by default Thinking
      ***REMOVED*** Sphinx will retry three times. Pass :retry_stale => 5 to retry five
      ***REMOVED*** times, and so on. If there are still missing ids on the last retry, they
      ***REMOVED*** are shown as nils.
      ***REMOVED*** 
      def search(*args)
        ThinkingSphinx::Search.new *search_options(args)
      end
      
      ***REMOVED*** Searches for results that match the parameters provided. Will only
      ***REMOVED*** return the ids for the matching objects. See ***REMOVED***search for syntax
      ***REMOVED*** examples.
      ***REMOVED***
      ***REMOVED*** Note that this only searches the Sphinx index, with no ActiveRecord
      ***REMOVED*** queries. Thus, if your index is not in sync with the database, this
      ***REMOVED*** method may return ids that no longer exist there.
      ***REMOVED***
      def search_for_ids(*args)
        ThinkingSphinx::Search.new *search_options(args, :ids_only => true)
      end
      
      ***REMOVED*** Checks if a document with the given id exists within a specific index.
      ***REMOVED*** Expected parameters:
      ***REMOVED***
      ***REMOVED*** - ID of the document
      ***REMOVED*** - Index to check within
      ***REMOVED*** - Options hash (defaults to {})
      ***REMOVED*** 
      ***REMOVED*** Example:
      ***REMOVED*** 
      ***REMOVED***   ThinkingSphinx.search_for_id(10, "user_core", :class => User)
      ***REMOVED*** 
      def search_for_id(id, index, options = {})
        ThinkingSphinx::Search.new(
          *search_options([],
            :ids_only => true,
            :index    => index,
            :id_range => id..id
          )
        ).any?
      end
      
      def count(*args)
        search_context ? super : search_count(*args)
      end
      
      def search_count(*args)
        search = ThinkingSphinx::Search.new(
          *search_options(args, :ids_only => true)
        )
        search.first ***REMOVED*** forces the query
        search.total_entries
      end
      
      ***REMOVED*** Model.facets *args
      ***REMOVED*** ThinkingSphinx.facets *args
      ***REMOVED*** ThinkingSphinx.facets *args, :all_facets  => true
      ***REMOVED*** ThinkingSphinx.facets *args, :class_facet     => false
      ***REMOVED*** 
      def facets(*args)
        ThinkingSphinx::FacetSearch.new *search_options(args)
      end
      
      private
      
      def search_options(args, options = {})
        options = args.extract_options!.merge(options)
        options[:classes] ||= classes_option
        args << options
      end
      
      def classes_option
        classes_option = [search_context].compact
        classes_option.empty? ? nil : classes_option
      end
    end
  end
end
