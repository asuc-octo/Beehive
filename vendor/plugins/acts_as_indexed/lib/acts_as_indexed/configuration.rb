***REMOVED*** ActsAsIndexed
***REMOVED*** Copyright (c) 2007 - 2010 Douglas F Shearer.
***REMOVED*** http://douglasfshearer.com
***REMOVED*** Distributed under the MIT license as included with this plugin.

module ActsAsIndexed
  ***REMOVED*** Used to set up and modify settings for acts_as_indexed.
  class Configuration
    
    ***REMOVED*** Sets the location for the index. Specify as an array. Heroku, for
    ***REMOVED*** example would use RAILS_ROOT/tmp/index, which would be set as
    ***REMOVED*** [Rails.root,'tmp','index]
    attr_accessor :index_file
    
    ***REMOVED*** Tuning value for the index partitioning. Larger values result in quicker
    ***REMOVED*** searches, but slower indexing. Default is 3.
    attr_reader :index_file_depth
    
    ***REMOVED*** Sets the minimum length for a word in a query. Words shorter than this
    ***REMOVED*** value are ignored in searches unless preceded by the '+' operator.
    ***REMOVED*** Default is 3.
    attr_reader :min_word_size
    
    def initialize
      @index_file = [Rails.root, 'index']
      @index_file_depth = 3
      @min_word_size = 3
    end
    
    def index_file_depth=(val)
      raise(ArgumentError, 'index_file_depth cannot be less than one (1)') if val < 1
      @index_file_depth = val
    end
    
    def min_word_size=(val)
      raise(ArgumentError, 'min_word_size cannot be less than one (1)') if val < 1
      @min_word_size = val
    end
    
  end
end