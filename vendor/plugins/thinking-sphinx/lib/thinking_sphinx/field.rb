module ThinkingSphinx
  ***REMOVED*** Fields - holding the string data which Sphinx indexes for your searches.
  ***REMOVED*** This class isn't really useful to you unless you're hacking around with the
  ***REMOVED*** internals of Thinking Sphinx - but hey, don't let that stop you.
  ***REMOVED***
  ***REMOVED*** One key thing to remember - if you're using the field manually to
  ***REMOVED*** generate SQL statements, you'll need to set the base model, and all the
  ***REMOVED*** associations. Which can get messy. Use Index.link!, it really helps.
  ***REMOVED*** 
  class Field < ThinkingSphinx::Property
    attr_accessor :sortable, :infixes, :prefixes
    
    ***REMOVED*** To create a new field, you'll need to pass in either a single Column
    ***REMOVED*** or an array of them, and some (optional) options. The columns are
    ***REMOVED*** references to the data that will make up the field.
    ***REMOVED***
    ***REMOVED*** Valid options are:
    ***REMOVED*** - :as       => :alias_name 
    ***REMOVED*** - :sortable => true
    ***REMOVED*** - :infixes  => true
    ***REMOVED*** - :prefixes => true
    ***REMOVED***
    ***REMOVED*** Alias is only required in three circumstances: when there's
    ***REMOVED*** another attribute or field with the same name, when the column name is
    ***REMOVED*** 'id', or when there's more than one column.
    ***REMOVED*** 
    ***REMOVED*** Sortable defaults to false - but is quite useful when set to true, as
    ***REMOVED*** it creates an attribute with the same string value (which Sphinx converts
    ***REMOVED*** to an integer value), which can be sorted by. Thinking Sphinx is smart
    ***REMOVED*** enough to realise that when you specify fields in sort statements, you
    ***REMOVED*** mean their respective attributes.
    ***REMOVED*** 
    ***REMOVED*** If you have partial matching enabled (ie: enable_star), then you can
    ***REMOVED*** specify certain fields to have their prefixes and infixes indexed. Keep
    ***REMOVED*** in mind, though, that Sphinx's default is _all_ fields - so once you
    ***REMOVED*** highlight a particular field, no other fields in the index will have
    ***REMOVED*** these partial indexes.
    ***REMOVED***
    ***REMOVED*** Here's some examples:
    ***REMOVED***
    ***REMOVED***   Field.new(
    ***REMOVED***     Column.new(:name)
    ***REMOVED***   )
    ***REMOVED***
    ***REMOVED***   Field.new(
    ***REMOVED***     [Column.new(:first_name), Column.new(:last_name)],
    ***REMOVED***     :as => :name, :sortable => true
    ***REMOVED***   )
    ***REMOVED*** 
    ***REMOVED***   Field.new(
    ***REMOVED***     [Column.new(:posts, :subject), Column.new(:posts, :content)],
    ***REMOVED***     :as => :posts, :prefixes => true
    ***REMOVED***   )
    ***REMOVED*** 
    def initialize(source, columns, options = {})
      super
      
      @sortable = options[:sortable] || false
      @infixes  = options[:infixes]  || false
      @prefixes = options[:prefixes] || false
      
      source.fields << self
    end
    
    ***REMOVED*** Get the part of the SELECT clause related to this field. Don't forget
    ***REMOVED*** to set your model and associations first though.
    ***REMOVED***
    ***REMOVED*** This will concatenate strings if there's more than one data source or
    ***REMOVED*** multiple data values (has_many or has_and_belongs_to_many associations).
    ***REMOVED*** 
    def to_select_sql
      clause = columns_with_prefixes.join(', ')
      
      clause = adapter.concatenate(clause)       if concat_ws?
      clause = adapter.group_concatenate(clause) if is_many?
      
      "***REMOVED***{clause} AS ***REMOVED***{quote_column(unique_name)}"
    end
  end
end
