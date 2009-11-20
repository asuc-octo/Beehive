***REMOVED*** encoding: utf-8
require "***REMOVED***{File.dirname(File.expand_path(__FILE__))}/../test_helper"

class ActsAsSolrTest < Test::Unit::TestCase
  
  fixtures :books, :movies, :electronics, :postings, :authors

  ***REMOVED*** Inserting new data into Solr and making sure it's getting indexed
  def test_insert_new_data
    assert_equal 2, Book.count_by_solr('ruby OR splinter OR bob')
    b = Book.create(:name => "Fuze in action", :author => "Bob Bobber", :category_id => 1)
    assert b.valid?
    assert_equal 3, Book.count_by_solr('ruby OR splinter OR bob')
  end
  
  ***REMOVED*** Check the type column stored in the index isn't stemmed by SOLR.  If it is stemmed,
  ***REMOVED*** then both Post and Posting will be stored as type:Post, so a query for Posts will
  ***REMOVED*** return Postings and vice versa
  
  def test_insert_new_data_doesnt_stem_type
    assert_equal 0, Post.count_by_solr('aardvark')
    p = Posting.new :name => 'aardvark', :description => "An interesting animal"
    p.guid = '12AB'
    p.save!
    assert_equal 0, Post.count_by_solr('aardvark')
  end

  def test_type_determined_from_database_if_not_explicitly_set
    assert Post.configuration[:solr_fields][:posted_at][:type] == :date
  end
  
  def test_search_includes_subclasses
    Novel.create! :name => 'Wuthering Heights', :author => 'Emily Bronte'
    Book.create! :name => 'Jane Eyre', :author => 'Charlotte Bronte'
    assert_equal 1, Novel.find_by_solr('Bronte').total_hits
    assert_equal 2, Book.find_by_solr('Bronte').total_hits
  end

  ***REMOVED*** Testing basic solr search:
  ***REMOVED***  Model.find_by_solr 'term'
  ***REMOVED*** Note that you're able to mix free-search with fields and boolean operators
  def test_find_by_solr_ruby
    ['ruby', 'dummy', 'name:ruby', 'name:dummy', 'name:ruby AND author:peter', 
      'author:peter AND ruby', 'peter dummy'].each do |term|
      records = Book.find_by_solr term
      assert_equal 1, records.total
      assert_equal "Peter McPeterson", records.docs.first.author
      assert_equal "Ruby for Dummies", records.docs.first.name
      assert_equal ({"id" => 2, 
                      "category_id" => 2, 
                      "name" => "Ruby for Dummies", 
                      "author" => "Peter McPeterson", "published_on" => (Date.today - 2.years), "type" => nil}), records.docs.first.attributes
    end
  end
  
  ***REMOVED*** Testing basic solr search:
  ***REMOVED***   Model.find_by_solr 'term'
  ***REMOVED*** Note that you're able to mix free-search with fields and boolean operators
  def test_find_by_solr_splinter
    ['splinter', 'name:splinter', 'name:splinter AND author:clancy', 
      'author:clancy AND splinter', 'cell tom'].each do |term|
      records = Book.find_by_solr term
      assert_equal 1, records.total
      assert_equal "Splinter Cell", records.docs.first.name
      assert_equal "Tom Clancy", records.docs.first.author
      assert_equal ({"id" => 1, "category_id" => 1, "name" => "Splinter Cell", 
                     "author" => "Tom Clancy", "published_on" => (Date.today - 1.year), "type" => nil}), records.docs.first.attributes
    end
  end
  
  ***REMOVED*** Testing basic solr search:
  ***REMOVED***   Model.find_by_solr 'term'
  ***REMOVED*** Note that you're able to mix free-search with fields and boolean operators
  def test_find_by_solr_ruby_or_splinter
    ['ruby OR splinter', 'ruby OR author:tom', 'name:cell OR author:peter', 'dummy OR cell'].each do |term|
      records = Book.find_by_solr term
      assert_equal 2, records.total
    end
  end
  
  ***REMOVED*** Testing search in indexed field methods:
  ***REMOVED*** 
  ***REMOVED*** class Movie < ActiveRecord::Base
  ***REMOVED***   acts_as_solr :fields => [:name, :description, :current_time]
  ***REMOVED*** 
  ***REMOVED***   def current_time
  ***REMOVED***     Time.now.to_s
  ***REMOVED***   end
  ***REMOVED*** 
  ***REMOVED*** end
  ***REMOVED*** 
  ***REMOVED*** The method current_time above gets indexed as being part of the
  ***REMOVED*** Movie model and it's available for search as well
  def test_find_with_dynamic_fields
    date = Time.now.strftime('%b %d %Y')
    ["dynamite AND ***REMOVED***{date}", "description:goofy AND ***REMOVED***{date}", "goofy napoleon ***REMOVED***{date}", 
      "goofiness ***REMOVED***{date}"].each do |term|
      records = Movie.find_by_solr term 
      assert_equal 1, records.total
      assert_equal ({"id" => 1, "name" => "Napoleon Dynamite", 
                     "description" => "Cool movie about a goofy guy"}), records.docs.first.attributes
    end
  end
  
  ***REMOVED*** Testing basic solr search that returns just the ids instead of the objects:
  ***REMOVED***   Model.find_id_by_solr 'term'
  ***REMOVED*** Note that you're able to mix free-search with fields and boolean operators
  def test_find_id_by_solr_ruby
    ['ruby', 'dummy', 'name:ruby', 'name:dummy', 'name:ruby AND author:peter', 
      'author:peter AND ruby'].each do |term|
      records = Book.find_id_by_solr term
      assert_equal 1, records.docs.size
      assert_equal [2], records.docs
    end
  end
  
  ***REMOVED*** Testing basic solr search that returns just the ids instead of the objects:
  ***REMOVED***   Model.find_id_by_solr 'term'
  ***REMOVED*** Note that you're able to mix free-search with fields and boolean operators
  def test_find_id_by_solr_splinter
    ['splinter', 'name:splinter', 'name:splinter AND author:clancy', 
      'author:clancy AND splinter'].each do |term|
      records = Book.find_id_by_solr term
      assert_equal 1, records.docs.size
      assert_equal [1], records.docs
    end
  end
  
  ***REMOVED*** Testing basic solr search that returns just the ids instead of the objects:
  ***REMOVED***   Model.find_id_by_solr 'term'
  ***REMOVED*** Note that you're able to mix free-search with fields and boolean operators
  def test_find_id_by_solr_ruby_or_splinter
    ['ruby OR splinter', 'ruby OR author:tom', 'name:cell OR author:peter', 
      'dummy OR cell'].each do |term|
      records = Book.find_id_by_solr term
      assert_equal 2, records.docs.size
      assert_equal [1,2], records.docs
    end
  end
  
  ***REMOVED*** Testing basic solr search that returns the total number of records found:
  ***REMOVED***   Model.find_count_by_solr 'term'
  ***REMOVED*** Note that you're able to mix free-search with fields and boolean operators
  def test_count_by_solr
    ['ruby', 'dummy', 'name:ruby', 'name:dummy', 'name:ruby AND author:peter', 
      'author:peter AND ruby'].each do |term|
      assert_equal 1, Book.count_by_solr(term), "there should only be 1 result for search: ***REMOVED***{term}"
    end
  end
  
  ***REMOVED*** Testing basic solr search that returns the total number of records found:
  ***REMOVED***   Model.find_count_by_solr 'term'
  ***REMOVED*** Note that you're able to mix free-search with fields and boolean operators
  def test_count_by_solr_splinter
    ['splinter', 'name:splinter', 'name:splinter AND author:clancy', 
      'author:clancy AND splinter', 'author:clancy cell'].each do |term|
      assert_equal 1, Book.count_by_solr(term)
    end
  end
  
  ***REMOVED*** Testing basic solr search that returns the total number of records found:
  ***REMOVED***   Model.find_count_by_solr 'term'
  ***REMOVED*** Note that you're able to mix free-search with fields and boolean operators
  def test_count_by_solr_ruby_or_splinter
    ['ruby OR splinter', 'ruby OR author:tom', 'name:cell OR author:peter', 'dummy OR cell'].each do |term|
      assert_equal 2, Book.count_by_solr(term)
    end
  end
    
  ***REMOVED*** Testing basic solr search with additional options:
  ***REMOVED*** Model.find_count_by_solr 'term', :limit => 10, :offset => 0
  def test_find_with_options
    [1,2].each do |count|
      records = Book.find_by_solr 'ruby OR splinter', :limit => count
      assert_equal count, records.docs.size
    end
  end
  
  ***REMOVED*** Testing self.rebuild_solr_index
  ***REMOVED*** - It makes sure the index is rebuilt after a data has been lost
  def test_rebuild_solr_index
    assert_equal 1, Book.count_by_solr('splinter')
    
    Book.find(:first).solr_destroy
    assert_equal 0, Book.count_by_solr('splinter')
    
    Book.rebuild_solr_index
    assert_equal 1, Book.count_by_solr('splinter')
  end
  
  ***REMOVED*** Testing instance methods:
  ***REMOVED*** - solr_save
  ***REMOVED*** - solr_destroy
  def test_solr_save_and_solr_destroy
    assert_equal 1, Book.count_by_solr('splinter')
  
    Book.find(:first).solr_destroy
    assert_equal 0, Book.count_by_solr('splinter')
    
    Book.find(:first).solr_save
    assert_equal 1, Book.count_by_solr('splinter')
  end
  
  ***REMOVED*** Testing the order of results
  def test_find_returns_records_in_order
    records = Book.find_by_solr 'ruby^5 OR splinter'
    ***REMOVED*** we boosted ruby so ruby should come first
  
    assert_equal 2, records.total
    assert_equal 'Ruby for Dummies', records.docs.first.name
    assert_equal 'Splinter Cell', records.docs.last.name    
  end
  
  ***REMOVED*** Testing solr search with optional :order argument
  def _test_with_order_option
    records = Movie.find_by_solr 'office^5 OR goofiness'
    assert_equal 'Hypnotized dude loves fishing but not working', records.docs.first.description
    assert_equal 'Cool movie about a goofy guy', records.docs.last.description
    
    records = Movie.find_by_solr 'office^5 OR goofiness', :order => 'description asc'
    assert_equal 'Cool movie about a goofy guy', records.docs.first.description
    assert_equal 'Hypnotized dude loves fishing but not working', records.docs.last.description
  end
  
  ***REMOVED*** Testing search with omitted :field_types should 
  ***REMOVED*** return the same result set as if when we use it
  def test_omit_field_types_in_search
    records  = Electronic.find_by_solr "price:[200 TO 599.99]"
    assert_match(/599/, records.docs.first.price)
    assert_match(/319/, records.docs.last.price)
    
    records  = Electronic.find_by_solr "price:[200 TO 599.99]", :order => 'price asc'
    assert_match(/319/, records.docs.first.price)
    assert_match(/599/, records.docs.last.price)
    
  end
  
  ***REMOVED*** Test to make sure the result returned when no matches
  ***REMOVED*** are found has the same structure when there are results
  def test_returns_no_matches
    records = Book.find_by_solr 'rubyist'
    assert_equal [], records.docs
    assert_equal 0, records.total
    
    records = Book.find_id_by_solr 'rubyist'
    assert_equal [], records.docs
    assert_equal 0, records.total
    
    records = Book.find_by_solr 'rubyist', :facets => {}
    assert_equal [], records.docs
    assert_equal 0, records.total
    assert_equal({"facet_fields"=>[]}, records.facets)
  end
  
  
  ***REMOVED*** Testing the :exclude_fields option when set in the
  ***REMOVED*** model to make sure it doesn't get indexed
  def test_exclude_fields_option
    records = Electronic.find_by_solr 'audiobooks OR latency'
    assert records.docs.empty?
    assert_equal 0, records.total
  
    assert_nothing_raised{
      records = Electronic.find_by_solr 'features:audiobooks'
      assert records.docs.empty?
      assert_equal 0, records.total
    }
  end
  
  ***REMOVED*** Testing the :auto_commit option set to false in the model
  ***REMOVED*** should not send the commit command to Solr
  def test_auto_commit_turned_off
    assert_equal 0, Author.count_by_solr('raymond chandler')
    
    original_count = Author.count
    Author.create(:name => 'Raymond Chandler', :biography => 'Writes noirish detective stories')
    
    assert_equal original_count + 1, Author.count
    assert_equal 0, Author.count_by_solr('raymond chandler')
  end
  
  ***REMOVED*** Testing models that use a different key as the primary key
  def test_search_on_model_with_string_id_field
    records = Posting.find_by_solr 'first^5 OR second'
    assert_equal 2, records.total
    assert_equal 'ABC-123', records.docs.first.guid
    assert_equal 'DEF-456', records.docs.last.guid
  end
  
  ***REMOVED*** Making sure the result set is ordered correctly even on
  ***REMOVED*** models that use a different key as the primary key
  def test_records_in_order_on_model_with_string_id_field
    records = Posting.find_by_solr 'first OR second^5'
    assert_equal 2, records.total
    assert_equal 'DEF-456', records.docs.first.guid
    assert_equal 'ABC-123', records.docs.last.guid
  end
  
  ***REMOVED*** Making sure the records are added when passing a batch size
  ***REMOVED*** to rebuild_solr_index
  def test_using_rebuild_solr_index_with_batch
    assert_equal 2, Movie.count_by_solr('office OR napoleon')
    Movie.find(:all).each(&:solr_destroy)
    assert_equal 0, Movie.count_by_solr('office OR napoleon')
    
    Movie.rebuild_solr_index 100
    assert_equal 2, Movie.count_by_solr('office OR napoleon')
  end
  
  ***REMOVED*** Making sure find_by_solr with scores actually return the scores
  ***REMOVED*** for each individual record
  def test_find_by_solr_with_score
    books = Book.find_by_solr 'ruby^10 OR splinter', :scores => true
    assert_equal 2, books.total
    assert_equal 0.41763234, books.max_score
    
    books.records.each { |book| assert_not_nil book.solr_score }
    assert_equal 0.41763234, books.docs.first.solr_score
    assert_equal 0.14354616, books.docs.last.solr_score
  end
  
  ***REMOVED*** Making sure nothing breaks when html entities are inside
  ***REMOVED*** the content to be indexed; and on the search as well.
  def test_index_and_search_with_html_entities
    description = "
    inverted exclamation mark  	&iexcl;  	&***REMOVED***161;
    ¤ 	currency 	&curren; 	&***REMOVED***164;
    ¢ 	cent 	&cent; 	&***REMOVED***162;
    £ 	pound 	&pound; 	&***REMOVED***163;
    ¥ 	yen 	&yen; 	&***REMOVED***165;
    ¦ 	broken vertical bar 	&brvbar; 	&***REMOVED***166;
    § 	section 	&sect; 	&***REMOVED***167;
    ¨ 	spacing diaeresis 	&uml; 	&***REMOVED***168;
    © 	copyright 	&copy; 	&***REMOVED***169;
    ª 	feminine ordinal indicator 	&ordf; 	&***REMOVED***170;
    « 	angle quotation mark (left) 	&laquo; 	&***REMOVED***171;
    ¬ 	negation 	&not; 	&***REMOVED***172;
    ­ 	soft hyphen 	&shy; 	&***REMOVED***173;
    ® 	registered trademark 	&reg; 	&***REMOVED***174;
    ™ 	trademark 	&trade; 	&***REMOVED***8482;
    ¯ 	spacing macron 	&macr; 	&***REMOVED***175;
    ° 	degree 	&deg; 	&***REMOVED***176;
    ± 	plus-or-minus  	&plusmn; 	&***REMOVED***177;
    ² 	superscript 2 	&sup2; 	&***REMOVED***178;
    ³ 	superscript 3 	&sup3; 	&***REMOVED***179;
    ´ 	spacing acute 	&acute; 	&***REMOVED***180;
    µ 	micro 	&micro; 	&***REMOVED***181;
    ¶ 	paragraph 	&para; 	&***REMOVED***182;
    · 	middle dot 	&middot; 	&***REMOVED***183;
    ¸ 	spacing cedilla 	&cedil; 	&***REMOVED***184;
    ¹ 	superscript 1 	&sup1; 	&***REMOVED***185;
    º 	masculine ordinal indicator 	&ordm; 	&***REMOVED***186;
    » 	angle quotation mark (right) 	&raquo; 	&***REMOVED***187;
    ¼ 	fraction 1/4 	&frac14; 	&***REMOVED***188;
    ½ 	fraction 1/2 	&frac12; 	&***REMOVED***189;
    ¾ 	fraction 3/4 	&frac34; 	&***REMOVED***190;
    ¿ 	inverted question mark 	&iquest; 	&***REMOVED***191;
    × 	multiplication 	&times; 	&***REMOVED***215;
    ÷ 	division 	&divide; 	&***REMOVED***247
        &hearts; &diams; &clubs; &spades;"
    
    author = Author.create(:name => "Test in Action&trade; - Copyright &copy; Bob", :biography => description)
    assert author.valid?
    author.solr_commit

    author = Author.find_by_solr 'trademark &copy &***REMOVED***190 &iexcl &***REMOVED***163'
    assert_equal 1, author.total
  end
  
  def test_operator_search_option
    assert_nothing_raised {
      books = Movie.find_by_solr "office napoleon", :operator => :or
      assert_equal 2, books.total
      
      books = Movie.find_by_solr "office napoleon", :operator => :and
      assert_equal 0, books.total
    }
    
    assert_raise RuntimeError do
      Movie.find_by_solr "office napoleon", :operator => :bad
    end
  end  
  
  ***REMOVED*** Making sure find_by_solr with scores actually return the scores
  ***REMOVED*** for each individual record and orders them accordingly
  def test_find_by_solr_order_by_score
    books = Book.find_by_solr 'ruby^10 OR splinter', {:scores => true, :order => 'score asc' }
    assert (books.docs.collect(&:solr_score).compact.size == books.docs.size), "Each book should have a score"
    assert_equal 0.41763234, books.docs.last.solr_score
    
    books = Book.find_by_solr 'ruby^10 OR splinter', {:scores => true, :order => 'score desc' }
    assert_equal 0.41763234, books.docs.first.solr_score
    assert_equal 0.14354616, books.docs.last.solr_score
  end
  
  ***REMOVED*** Search based on fields with the :date format
  def test_indexed_date_field_format
    movies = Movie.find_by_solr 'time_on_xml:[NOW-1DAY TO NOW]'
    assert_equal 2, movies.total
  end
  
  def test_query_time_is_returned
    results = Book.find_by_solr('ruby')
    assert_not_nil(results.query_time)
    assert_equal(results.query_time.class,Fixnum)
  end
  
  def test_should_not_index_the_record_when_offline_proc_returns_true
    Gadget.search_disabled = true
    gadget = Gadget.create(:name => "flipvideo mino")
    assert_equal 0, Gadget.find_id_by_solr('flipvideo').total
  end
end
