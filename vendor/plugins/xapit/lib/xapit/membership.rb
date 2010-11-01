module Xapit
  ***REMOVED*** Use "include Xapit::Membership" on a class to allow xapian searching on it. This is automatically included
  ***REMOVED*** in ActiveRecord::Base so you do not need to do anything there.
  module Membership
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      ***REMOVED*** Simply call "xapit" on a class and pass a block to define the indexed attributes.
      ***REMOVED*** 
      ***REMOVED***   class Article < ActiveRecord::Base
      ***REMOVED***     xapit do |index|
      ***REMOVED***       index.text :name, :content
      ***REMOVED***       index.field :category_id
      ***REMOVED***       index.facet :author_name, "Author"
      ***REMOVED***       index.sortable :id, :category_id
      ***REMOVED***     end
      ***REMOVED***   end
      ***REMOVED*** 
      ***REMOVED*** First we index "name" and "content" attributes for full text searching. The "category_id" field is indexed for :conditions searching. The "author_name" is indexed as a facet with "Author" being the display name of the facet. See the facets section below for details. Finally the "id" and "category_id" attributes are indexed as sortable attributes so they can be included in the :order option in a search.
      ***REMOVED*** 
      ***REMOVED*** Because the indexing happens in Ruby these attributes do no have to be database columns. They can be simple Ruby methods. For example, the "author_name" attribute mentioned above can be defined like this.
      ***REMOVED*** 
      ***REMOVED***   def author_name
      ***REMOVED***     author.name
      ***REMOVED***   end
      ***REMOVED*** 
      ***REMOVED*** This way you can create a completely custom facet by simply defining your own method
      ***REMOVED*** 
      ***REMOVED*** You can also pass any find options to the xapit method to determine what gets indexed and improve performance with eager loading or a different batch size.
      ***REMOVED*** 
      ***REMOVED***   xapit(:batch_size => 100, :include => :author, :conditions => { :visible => true })
      ***REMOVED***
      ***REMOVED*** If you pass in a block you can customize how the text words will be devided (instead of by simply white space).
      ***REMOVED*** 
      ***REMOVED***   xapit do |index|
      ***REMOVED***     index.text(:keywords) { |words| words.split(', ') }
      ***REMOVED***   end
      ***REMOVED*** 
      ***REMOVED*** You can specify a :weight option to give a text attribute more importance. This will cause search terms matching
      ***REMOVED*** that attribute to have a higher rank. The default weight is 1. Decimal (0.5) weight values are not supported.
      ***REMOVED***
      ***REMOVED***   index.text :name, :weight => 10
      ***REMOVED*** 
      def xapit(*args)
        @xapit_index_blueprint = IndexBlueprint.new(self, *args)
        yield(@xapit_index_blueprint)
        include AdditionalMethods
        include XapitSync::Membership if defined? XapitSync
      end
    end
    
    module AdditionalMethods
      def self.included(base)
        base.extend ClassMethods
        base.send(:attr_accessor, :xapit_relevance) ***REMOVED*** is there a better way to do this?
      end
      
      ***REMOVED*** Find similar records to the given model. It takes the same arguments as Membership::AdditionalMethods::ClassMethods***REMOVED***search to further narrow down the results.
      def search_similar(*args)
        Collection.search_similar(self, *args)
      end
    
      module ClassMethods
        ***REMOVED*** Used to perform a search on a model.
        ***REMOVED***   
        ***REMOVED***   ***REMOVED*** perform a simple full text search
        ***REMOVED***   @articles = Article.search("phone")
        ***REMOVED***   
        ***REMOVED***   ***REMOVED*** add pagination if you're using will_paginate
        ***REMOVED***   @articles = Article.search("phone", :per_page => 10, :page => params[:page])
        ***REMOVED***   
        ***REMOVED***   ***REMOVED*** search based on indexed fields
        ***REMOVED***   @articles = Article.search("phone", :conditions => { :category_id => params[:category_id] })
        ***REMOVED***   
        ***REMOVED***   ***REMOVED*** search for multiple negative conditions (doesn't match 3, 5, or 8)
        ***REMOVED***   @articles = Article.search(:not_conditions => { :category_id => [3, 5, 8] })
        ***REMOVED***   
        ***REMOVED***   ***REMOVED*** search for range of conditions by number
        ***REMOVED***   @articles = Article.search(:conditions => { :released_at => 2.years.ago..Time.now })
        ***REMOVED***   
        ***REMOVED***   ***REMOVED*** manually sort based on any number of indexed fields, sort defaults to most relevant
        ***REMOVED***   @articles = Article.search("phone", :order => [:category_id, :id], :descending => true)
        ***REMOVED***
        ***REMOVED***   ***REMOVED*** basic boolean matching is supported
        ***REMOVED***   @articles = Article.search("phone OR fax NOT email")
        ***REMOVED***
        ***REMOVED***   ***REMOVED*** field conditions in query string
        ***REMOVED***   @articles = Article.search("priority:3")
        ***REMOVED***
        ***REMOVED***   ***REMOVED*** no need to specify first query string when searching all records
        ***REMOVED***   @articles = Article.search(:conditions => { :category_id => params[:category_id] })
        ***REMOVED***
        ***REMOVED***   ***REMOVED*** search partial terms with asterisk (only supported at end of term)
        ***REMOVED***   @articles = Article.search("sab*", :conditions => { :name => "Din*" })
        ***REMOVED***
        ***REMOVED***   ***REMOVED*** search multiple conditions with OR by passing an array
        ***REMOVED***   @articles = Article.search(:conditions => [{ :category_id => 1 }, { :priority => 2 }])
        ***REMOVED***
        def search(*args)
          Collection.new(self, *args)
        end
      
        ***REMOVED*** The Xapit::IndexBlueprint object used for this class.
        def xapit_index_blueprint
          @xapit_index_blueprint
        end
        
        ***REMOVED*** The Xapit::AbstractAdapter used to perform database queries on.
        def xapit_adapter
          @xapit_adapter ||= begin
            adapter_class = AbstractAdapter.subclasses.detect { |a| a.for_class?(self) }
            if adapter_class
              adapter_class.new(self)
            else
              raise "Unable to find Xapit adapter for class ***REMOVED***{self.name}"
            end
          end
        end
        
        ***REMOVED*** Finds a Xapit::FacetBlueprint for the given attribute.
        def xapit_facet_blueprint(attribute)
          result = xapit_index_blueprint.facets.detect { |f| f.attribute.to_s == attribute.to_s }
          raise "Unable to find facet blueprint for ***REMOVED***{attribute} on ***REMOVED***{name}" if result.nil?
          result
        end
      end
    end
  end
end

if defined? ActiveRecord
  ActiveRecord::Base.class_eval do
    include Xapit::Membership
  end
end
