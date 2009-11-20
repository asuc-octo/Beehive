require File.join(File.dirname(__FILE__), '../test_helper')

class AssociationIndexingTest < Test::Unit::TestCase
  
  fixtures :categories, :books 
  
  ***REMOVED*** Testing the association indexing with has_many:
  ***REMOVED*** 
  ***REMOVED*** class Category < ActiveRecord::Base
  ***REMOVED***   has_many :books
  ***REMOVED***   acts_as_solr :include => [:books]
  ***REMOVED*** end
  ***REMOVED*** 
  ***REMOVED*** Note that some of the search terms below are from the 'books'
  ***REMOVED*** table, but get indexed as being a part of Category
  def test_search_on_fields_in_has_many_association
    ['thriller', 'novel', 'splinter', 'clancy', 'tom clancy thriller'].each do |term|
      assert_equal 1, Category.count_by_solr(term), "expected one result: ***REMOVED***{term}"
    end
  end
  
  ***REMOVED*** Testing the association indexing with belongs_to:
  ***REMOVED*** 
  ***REMOVED*** class Book < ActiveRecord::Base
  ***REMOVED***   belongs_to :category
  ***REMOVED***   acts_as_solr :include => [:category]
  ***REMOVED*** end
  ***REMOVED*** 
  ***REMOVED*** Note that some of the search terms below are from the 'categories'
  ***REMOVED*** table, but get indexed as being a part of Book
  def test_search_on_fields_in_belongs_to_association
    ['splinter', 'clancy', 'tom clancy thriller', 'splinter novel'].each do |term|
      assert_equal 1, Book.count_by_solr(term), "expected one result: ***REMOVED***{term}"
    end
  end

end
