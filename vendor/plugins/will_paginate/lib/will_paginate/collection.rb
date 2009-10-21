module WillPaginate
  ***REMOVED*** = Invalid page number error
  ***REMOVED*** This is an ArgumentError raised in case a page was requested that is either
  ***REMOVED*** zero or negative number. You should decide how do deal with such errors in
  ***REMOVED*** the controller.
  ***REMOVED***
  ***REMOVED*** If you're using Rails 2, then this error will automatically get handled like
  ***REMOVED*** 404 Not Found. The hook is in "will_paginate.rb":
  ***REMOVED***
  ***REMOVED***   ActionController::Base.rescue_responses['WillPaginate::InvalidPage'] = :not_found
  ***REMOVED***
  ***REMOVED*** If you don't like this, use your preffered method of rescuing exceptions in
  ***REMOVED*** public from your controllers to handle this differently. The +rescue_from+
  ***REMOVED*** method is a nice addition to Rails 2.
  ***REMOVED***
  ***REMOVED*** This error is *not* raised when a page further than the last page is
  ***REMOVED*** requested. Use <tt>WillPaginate::Collection***REMOVED***out_of_bounds?</tt> method to
  ***REMOVED*** check for those cases and manually deal with them as you see fit.
  class InvalidPage < ArgumentError
    def initialize(page, page_num)
      super "***REMOVED***{page.inspect} given as value, which translates to '***REMOVED***{page_num}' as page number"
    end
  end
  
  ***REMOVED*** = The key to pagination
  ***REMOVED*** Arrays returned from paginating finds are, in fact, instances of this little
  ***REMOVED*** class. You may think of WillPaginate::Collection as an ordinary array with
  ***REMOVED*** some extra properties. Those properties are used by view helpers to generate
  ***REMOVED*** correct page links.
  ***REMOVED***
  ***REMOVED*** WillPaginate::Collection also assists in rolling out your own pagination
  ***REMOVED*** solutions: see +create+.
  ***REMOVED*** 
  ***REMOVED*** If you are writing a library that provides a collection which you would like
  ***REMOVED*** to conform to this API, you don't have to copy these methods over; simply
  ***REMOVED*** make your plugin/gem dependant on the "mislav-will_paginate" gem:
  ***REMOVED***
  ***REMOVED***   gem 'mislav-will_paginate'
  ***REMOVED***   require 'will_paginate/collection'
  ***REMOVED***   
  ***REMOVED***   ***REMOVED*** WillPaginate::Collection is now available for use
  class Collection < Array
    attr_reader :current_page, :per_page, :total_entries, :total_pages

    ***REMOVED*** Arguments to the constructor are the current page number, per-page limit
    ***REMOVED*** and the total number of entries. The last argument is optional because it
    ***REMOVED*** is best to do lazy counting; in other words, count *conditionally* after
    ***REMOVED*** populating the collection using the +replace+ method.
    def initialize(page, per_page, total = nil)
      @current_page = page.to_i
      raise InvalidPage.new(page, @current_page) if @current_page < 1
      @per_page = per_page.to_i
      raise ArgumentError, "`per_page` setting cannot be less than 1 (***REMOVED***{@per_page} given)" if @per_page < 1
      
      self.total_entries = total if total
    end

    ***REMOVED*** Just like +new+, but yields the object after instantiation and returns it
    ***REMOVED*** afterwards. This is very useful for manual pagination:
    ***REMOVED***
    ***REMOVED***   @entries = WillPaginate::Collection.create(1, 10) do |pager|
    ***REMOVED***     result = Post.find(:all, :limit => pager.per_page, :offset => pager.offset)
    ***REMOVED***     ***REMOVED*** inject the result array into the paginated collection:
    ***REMOVED***     pager.replace(result)
    ***REMOVED***
    ***REMOVED***     unless pager.total_entries
    ***REMOVED***       ***REMOVED*** the pager didn't manage to guess the total count, do it manually
    ***REMOVED***       pager.total_entries = Post.count
    ***REMOVED***     end
    ***REMOVED***   end
    ***REMOVED***
    ***REMOVED*** The possibilities with this are endless. For another example, here is how
    ***REMOVED*** WillPaginate used to define pagination for Array instances:
    ***REMOVED***
    ***REMOVED***   Array.class_eval do
    ***REMOVED***     def paginate(page = 1, per_page = 15)
    ***REMOVED***       WillPaginate::Collection.create(page, per_page, size) do |pager|
    ***REMOVED***         pager.replace self[pager.offset, pager.per_page].to_a
    ***REMOVED***       end
    ***REMOVED***     end
    ***REMOVED***   end
    ***REMOVED***
    ***REMOVED*** The Array***REMOVED***paginate API has since then changed, but this still serves as a
    ***REMOVED*** fine example of WillPaginate::Collection usage.
    def self.create(page, per_page, total = nil)
      pager = new(page, per_page, total)
      yield pager
      pager
    end

    ***REMOVED*** Helper method that is true when someone tries to fetch a page with a
    ***REMOVED*** larger number than the last page. Can be used in combination with flashes
    ***REMOVED*** and redirecting.
    def out_of_bounds?
      current_page > total_pages
    end

    ***REMOVED*** Current offset of the paginated collection. If we're on the first page,
    ***REMOVED*** it is always 0. If we're on the 2nd page and there are 30 entries per page,
    ***REMOVED*** the offset is 30. This property is useful if you want to render ordinals
    ***REMOVED*** side by side with records in the view: simply start with offset + 1.
    def offset
      (current_page - 1) * per_page
    end

    ***REMOVED*** current_page - 1 or nil if there is no previous page
    def previous_page
      current_page > 1 ? (current_page - 1) : nil
    end

    ***REMOVED*** current_page + 1 or nil if there is no next page
    def next_page
      current_page < total_pages ? (current_page + 1) : nil
    end
    
    ***REMOVED*** sets the <tt>total_entries</tt> property and calculates <tt>total_pages</tt>
    def total_entries=(number)
      @total_entries = number.to_i
      @total_pages   = (@total_entries / per_page.to_f).ceil
    end

    ***REMOVED*** This is a magic wrapper for the original Array***REMOVED***replace method. It serves
    ***REMOVED*** for populating the paginated collection after initialization.
    ***REMOVED***
    ***REMOVED*** Why magic? Because it tries to guess the total number of entries judging
    ***REMOVED*** by the size of given array. If it is shorter than +per_page+ limit, then we
    ***REMOVED*** know we're on the last page. This trick is very useful for avoiding
    ***REMOVED*** unnecessary hits to the database to do the counting after we fetched the
    ***REMOVED*** data for the current page.
    ***REMOVED***
    ***REMOVED*** However, after using +replace+ you should always test the value of
    ***REMOVED*** +total_entries+ and set it to a proper value if it's +nil+. See the example
    ***REMOVED*** in +create+.
    def replace(array)
      result = super
      
      ***REMOVED*** The collection is shorter then page limit? Rejoice, because
      ***REMOVED*** then we know that we are on the last page!
      if total_entries.nil? and length < per_page and (current_page == 1 or length > 0)
        self.total_entries = offset + length
      end

      result
    end
  end
end
