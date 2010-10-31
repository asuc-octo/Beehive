***REMOVED*** :title:Ruby Xapian bindings
***REMOVED*** =Ruby Xapian bindings
***REMOVED***
***REMOVED*** Original version by Paul Legato (plegato@nks.net), 4/20/06.
***REMOVED***
***REMOVED*** Copyright (C) 2006 Networked Knowledge Systems, Inc.
***REMOVED*** Copyright (C) 2008 Olly Betts
***REMOVED*** Copyright (C) 2010 Richard Boulton
***REMOVED***
***REMOVED*** This program is free software; you can redistribute it and/or
***REMOVED*** modify it under the terms of the GNU General Public License as
***REMOVED*** published by the Free Software Foundation; either version 2 of the
***REMOVED*** License, or (at your option) any later version.
***REMOVED***
***REMOVED*** This program is distributed in the hope that it will be useful,
***REMOVED*** but WITHOUT ANY WARRANTY; without even the implied warranty of
***REMOVED*** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
***REMOVED*** GNU General Public License for more details.
***REMOVED***
***REMOVED*** You should have received a copy of the GNU General Public License
***REMOVED*** along with this program; if not, write to the Free Software
***REMOVED*** Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301
***REMOVED*** USA
***REMOVED***
***REMOVED*** ==Underscore methods
***REMOVED*** Note: Methods whose names start with an underscore character _ are internal
***REMOVED*** methods from the C++ API. Their functionality is not accessible in a
***REMOVED*** Ruby-friendly way, so this file provides wrapper code to make it easier to
***REMOVED*** use them from a Ruby programming idiom.  Most are also dangerous insofar as
***REMOVED*** misusing them can cause your program to segfault.  In particular, all of
***REMOVED*** Xapian's *Iterator classes are wrapped into nice Ruby-friendly Arrays.
***REMOVED***
***REMOVED*** It should never be necessary to use any method whose name starts with an
***REMOVED*** underscore from user-level code. Make sure you are _VERY_ certain that you
***REMOVED*** know exactly what you're doing if you do use one of these methods. Beware.
***REMOVED*** You've been warned...
***REMOVED***


module Xapian
  ***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** load the SWIG-generated library
  require '_xapian'


  ***REMOVED*** iterate over two dangerous iterators (i.e. those that can cause segfaults
  ***REMOVED*** if used improperly.)
  ***REMOVED*** Return the results as an Array.
  ***REMOVED*** Users should never need to use this method.
  ***REMOVED***
  ***REMOVED*** Takes a block that returns some appropriate Ruby object to wrap the
  ***REMOVED*** underlying Iterator
  def _safelyIterate(dangerousStart, dangerousEnd) ***REMOVED***:nodoc:
    retval = Array.new
    
    item = dangerousStart
    lastTerm = dangerousEnd
    
    return retval if dangerousStart.equals(dangerousEnd)

    begin      
      retval.push(yield(item))
      item.next()
    end while not item.equals(lastTerm) ***REMOVED*** must use primitive C++ comparator 
    
    return retval
  end ***REMOVED*** _safelyIterate
  module_function :_safelyIterate

  ***REMOVED***--
  ***REMOVED******REMOVED******REMOVED*** safe Ruby wrapper for the dangerous C++ Xapian::TermIterator class
  class Xapian::Term
    attr_accessor :term, :wdf, :termfreq

    def initialize(term, wdf=nil, termfreq=nil)
      @term = term
      @wdf = wdf
      @termfreq = termfreq
    end

    def ==(other)
      return other.is_a?(Xapian::Term) && other.term == @term && other.wdf == @wdf && other.termfreq == @termfreq
    end
  end ***REMOVED*** class Term

  ***REMOVED******REMOVED******REMOVED*** Ruby wrapper for a Match, i.e. a Xapian::MSetIterator (Match Set) in C++.
  ***REMOVED*** it's no longer an iterator in the Ruby version, but we want to preserve its
  ***REMOVED*** non-iterative data.
  ***REMOVED*** (MSetIterator is not dangerous, but it is inconvenient to use from a Ruby
  ***REMOVED*** idiom, so we wrap it..)
  class Xapian::Match     
    attr_accessor :docid, :document, :rank, :weight, :collapse_count, :percent

    def initialize(docid, document, rank, weight, collapse_count, percent)
      @docid = docid
      @document = document
      @rank = rank
      @weight = weight
      @collapse_count = collapse_count
      @percent = percent
    end ***REMOVED*** initialize

    def ==(other)
      return other.is_a?(Xapian::Match) && other.docid == @docid && other.rank == @rank && 
        other.weight == @weight && other.collapse_count == @collapse_count && other.percent == @percent
    end
  end ***REMOVED*** class Xapian::Match

  ***REMOVED*** Ruby wrapper for an ExpandTerm, i.e. a Xapian::ESetIterator in C++
  ***REMOVED*** Not dangerous, but inconvenient to use from a Ruby programming idiom, so we
  ***REMOVED*** wrap it.
  class Xapian::ExpandTerm
    attr_accessor :name, :weight

    def initialize(name, weight)
      @name = name
      @weight = weight
    end ***REMOVED*** initialize

    def ==(other)
      return other.is_a?(Xapian::ExpandTerm) && other.name == @name && other.weight == @weight
    end

  end ***REMOVED*** Xapian::ExpandTerm

  ***REMOVED*** Ruby wrapper for Xapian::ValueIterator
  class Xapian::Value
    attr_accessor :value, :valueno, :docid
    
    def initialize(value, valueno, docid)
      @value = value
      @valueno = valueno
      @docid = docid
    end ***REMOVED*** initialize

    def ==(other)
      return other.is_a?(Xapian::Value) && other.value == @value && other.valueno == @valueno && other.docid == @docid
    end
  end ***REMOVED*** Xapian::Value

  ***REMOVED*** Refer to the
  ***REMOVED*** {Xapian::Document C++ API documentation}[http://xapian.org/docs/apidoc/html/classXapian_1_1Document.html]
  ***REMOVED*** for methods not specific to Ruby.
  ***REMOVED***--
  ***REMOVED*** Extend Xapian::Document with a nice wrapper for its nasty input_iterators
  class Xapian::Document
    def terms
      Xapian._safelyIterate(self._dangerous_termlist_begin(), self._dangerous_termlist_end()) { |item|
        Xapian::Term.new(item.term, item.wdf)
      }
    end ***REMOVED*** terms

    def values
      Xapian._safelyIterate(self._dangerous_values_begin(), self._dangerous_values_end()) { |item|
        Xapian::Value.new(item.value, item.valueno, 0)
      }
    end ***REMOVED*** terms

  end ***REMOVED*** class Xapian::Document

  ***REMOVED*** Refer to the
  ***REMOVED*** {Xapian::Query C++ API documentation}[http://xapian.org/docs/apidoc/html/classXapian_1_1Query.html]
  ***REMOVED*** for methods not specific to Ruby.
  ***REMOVED***--
  ***REMOVED*** Extend Xapian::Query with a nice wrapper for its dangerous iterators
  class Xapian::Query
    def terms
      Xapian._safelyIterate(self._dangerous_terms_begin(), self._dangerous_terms_end()) { |item|
        Xapian::Term.new(item.term, item.wdf)
        ***REMOVED*** termfreq is not supported by TermIterators from Queries
      }
    end
  end ***REMOVED*** Xapian::Query

  ***REMOVED*** Refer to the
  ***REMOVED*** {Xapian::Enquire C++ API documentation}[http://xapian.org/docs/apidoc/html/classXapian_1_1Enquire.html]
  ***REMOVED*** for methods not specific to Ruby.
  ***REMOVED***--
  ***REMOVED*** Extend Xapian::Enquire with a nice wrapper for its dangerous iterators
  class Xapian::Enquire
    ***REMOVED*** Get matching terms for some document.
    ***REMOVED*** document can be either a Xapian::DocID or a Xapian::MSetIterator
    def matching_terms(document)
      Xapian._safelyIterate(self._dangerous_matching_terms_begin(document), 
                            self._dangerous_matching_terms_end(document)) { |item|
        Xapian::Term.new(item.term, item.wdf)
      }
    end
  end ***REMOVED*** Xapian::Enquire

  ***REMOVED*** Refer to the
  ***REMOVED*** {Xapian::MSet C++ API documentation}[http://xapian.org/docs/apidoc/html/classXapian_1_1MSet.html]
  ***REMOVED*** for methods not specific to Ruby.
  ***REMOVED***--
  ***REMOVED*** MSetIterators are not dangerous, just inconvenient to use within a Ruby
  ***REMOVED*** programming idiom. So we wrap them.
  class Xapian::MSet
    def matches
      Xapian._safelyIterate(self._begin(), 
                            self._end()) { |item|
        Xapian::Match.new(item.docid, item.document, item.rank, item.weight, item.collapse_count, item.percent)
      }

    end ***REMOVED*** matches
  end ***REMOVED*** Xapian::MSet

  ***REMOVED*** Refer to the
  ***REMOVED*** {Xapian::ESet C++ API documentation}[http://xapian.org/docs/apidoc/html/classXapian_1_1ESet.html]
  ***REMOVED*** for methods not specific to Ruby.
  ***REMOVED***--
  ***REMOVED*** ESetIterators are not dangerous, just inconvenient to use within a Ruby
  ***REMOVED*** programming idiom. So we wrap them.
  class Xapian::ESet
    def terms
      Xapian._safelyIterate(self._begin(), 
                            self._end()) { |item|
	***REMOVED*** note: in the ExpandTerm wrapper, we implicitly rename
	***REMOVED*** ESetIterator***REMOVED***term() (defined in xapian.i) to ExpandTerm***REMOVED***term()
        Xapian::ExpandTerm.new(item.term, item.weight)
      }

    end ***REMOVED*** terms
  end ***REMOVED*** Xapian::ESet


  ***REMOVED***--
  ***REMOVED*** Wrapper for the C++ class Xapian::PostingIterator
  class Xapian::Posting
    attr_accessor :docid, :doclength, :wdf

    def initialize(docid, doclength, wdf)
      @docid = docid
      @doclength = doclength
      @wdf = wdf
    end

    def ==(other)
      return other.is_a?(Xapian::Posting) && other.docid == @docid && other.doclength == @doclength &&
        other.wdf == @wdf
    end
  end ***REMOVED*** Xapian::Posting

  ***REMOVED*** Refer to the
  ***REMOVED*** {Xapian::Database C++ API documentation}[http://xapian.org/docs/apidoc/html/classXapian_1_1Database.html]
  ***REMOVED*** for methods not specific to Ruby.
  ***REMOVED***--
  ***REMOVED*** Wrap some dangerous iterators.
  class Xapian::Database
    ***REMOVED*** Returns an Array of all Xapian::Terms for this database.
    def allterms
      Xapian._safelyIterate(self._dangerous_allterms_begin(), 
                            self._dangerous_allterms_end()) { |item|
        Xapian::Term.new(item.term, 0, item.termfreq)
      }
    end ***REMOVED*** allterms

    ***REMOVED*** Returns an Array of Xapian::Postings for the given term.
    ***REMOVED*** term is a string.
    def postlist(term)
      Xapian._safelyIterate(self._dangerous_postlist_begin(term), 
                            self._dangerous_postlist_end(term)) { |item|
        Xapian::Posting.new(item.docid, item.doclength, item.wdf)
      }      
    end ***REMOVED*** postlist(term)

    ***REMOVED*** Returns an Array of Terms for the given docid.
    def termlist(docid)
      Xapian._safelyIterate(self._dangerous_termlist_begin(docid),
                            self._dangerous_termlist_end(docid)) { |item|
        Xapian::Term.new(item.term, item.wdf, item.termfreq)
      }
    end ***REMOVED*** termlist(docid)
    
    ***REMOVED*** Returns an Array of Xapian::Termpos objects for the given term (a String)
    ***REMOVED*** in the given docid.
    def positionlist(docid, term)
      Xapian._safelyIterate(self._dangerous_positionlist_begin(docid, term),
                            self._dangerous_positionlist_end(docid, term)) { |item|
        item.termpos
      }
    end ***REMOVED*** positionlist

    ***REMOVED*** Returns an Array of Xapian::Value objects for the given slot in the
    ***REMOVED*** database.
    def valuestream(slot)
      Xapian._safelyIterate(self._dangerous_valuestream_begin(slot),
                            self._dangerous_valuestream_end(slot)) { |item|
        Xapian::Value.new(item.value, slot, item.docid)
      }
    end ***REMOVED*** positionlist
  end ***REMOVED*** Xapian::Database

  ***REMOVED*** Refer to the
  ***REMOVED*** {Xapian::ValueCountMatchSpy C++ API documentation}[http://xapian.org/docs/apidoc/html/classXapian_1_1ValueCountMatchSpy.html]
  ***REMOVED*** for methods not specific to Ruby.
  ***REMOVED***--
  ***REMOVED*** Wrap some dangerous iterators.
  class Xapian::ValueCountMatchSpy
    ***REMOVED*** Returns an Array of all the values seen, in alphabetical order
    def values()
      Xapian._safelyIterate(self._dangerous_values_begin(),
                            self._dangerous_values_end()) { |item|
        Xapian::Term.new(item.term, 0, item.termfreq)
      }
    end ***REMOVED*** allterms

    ***REMOVED*** Returns an Array of the top values seen, by frequency
    def top_values(maxvalues)
      Xapian._safelyIterate(self._dangerous_top_values_begin(maxvalues),
                            self._dangerous_top_values_end(maxvalues)) { |item|
        Xapian::Term.new(item.term, 0, item.termfreq)
      }
    end ***REMOVED*** allterms
  end ***REMOVED*** Xapian::Database

end ***REMOVED*** Xapian module
