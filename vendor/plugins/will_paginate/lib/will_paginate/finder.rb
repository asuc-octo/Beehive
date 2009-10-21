require 'will_paginate/core_ext'

module WillPaginate
  ***REMOVED*** A mixin for ActiveRecord::Base. Provides +per_page+ class method
  ***REMOVED*** and hooks things up to provide paginating finders.
  ***REMOVED***
  ***REMOVED*** Find out more in WillPaginate::Finder::ClassMethods
  ***REMOVED***
  module Finder
    def self.included(base)
      base.extend ClassMethods
      class << base
        alias_method_chain :method_missing, :paginate
        ***REMOVED*** alias_method_chain :find_every,     :paginate
        define_method(:per_page) { 30 } unless respond_to?(:per_page)
      end
    end

    ***REMOVED*** = Paginating finders for ActiveRecord models
    ***REMOVED*** 
    ***REMOVED*** WillPaginate adds +paginate+, +per_page+ and other methods to
    ***REMOVED*** ActiveRecord::Base class methods and associations. It also hooks into
    ***REMOVED*** +method_missing+ to intercept pagination calls to dynamic finders such as
    ***REMOVED*** +paginate_by_user_id+ and translate them to ordinary finders
    ***REMOVED*** (+find_all_by_user_id+ in this case).
    ***REMOVED*** 
    ***REMOVED*** In short, paginating finders are equivalent to ActiveRecord finders; the
    ***REMOVED*** only difference is that we start with "paginate" instead of "find" and
    ***REMOVED*** that <tt>:page</tt> is required parameter:
    ***REMOVED***
    ***REMOVED***   @posts = Post.paginate :all, :page => params[:page], :order => 'created_at DESC'
    ***REMOVED*** 
    ***REMOVED*** In paginating finders, "all" is implicit. There is no sense in paginating
    ***REMOVED*** a single record, right? So, you can drop the <tt>:all</tt> argument:
    ***REMOVED*** 
    ***REMOVED***   Post.paginate(...)              =>  Post.find :all
    ***REMOVED***   Post.paginate_all_by_something  =>  Post.find_all_by_something
    ***REMOVED***   Post.paginate_by_something      =>  Post.find_all_by_something
    ***REMOVED***
    ***REMOVED*** == The importance of the <tt>:order</tt> parameter
    ***REMOVED***
    ***REMOVED*** In ActiveRecord finders, <tt>:order</tt> parameter specifies columns for
    ***REMOVED*** the <tt>ORDER BY</tt> clause in SQL. It is important to have it, since
    ***REMOVED*** pagination only makes sense with ordered sets. Without the <tt>ORDER
    ***REMOVED*** BY</tt> clause, databases aren't required to do consistent ordering when
    ***REMOVED*** performing <tt>SELECT</tt> queries; this is especially true for
    ***REMOVED*** PostgreSQL.
    ***REMOVED***
    ***REMOVED*** Therefore, make sure you are doing ordering on a column that makes the
    ***REMOVED*** most sense in the current context. Make that obvious to the user, also.
    ***REMOVED*** For perfomance reasons you will also want to add an index to that column.
    module ClassMethods
      ***REMOVED*** This is the main paginating finder.
      ***REMOVED***
      ***REMOVED*** == Special parameters for paginating finders
      ***REMOVED*** * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
      ***REMOVED*** * <tt>:per_page</tt> -- defaults to <tt>CurrentModel.per_page</tt> (which is 30 if not overridden)
      ***REMOVED*** * <tt>:total_entries</tt> -- use only if you manually count total entries
      ***REMOVED*** * <tt>:count</tt> -- additional options that are passed on to +count+
      ***REMOVED*** * <tt>:finder</tt> -- name of the ActiveRecord finder used (default: "find")
      ***REMOVED***
      ***REMOVED*** All other options (+conditions+, +order+, ...) are forwarded to +find+
      ***REMOVED*** and +count+ calls.
      def paginate(*args)
        options = args.pop
        page, per_page, total_entries = wp_parse_options(options)
        finder = (options[:finder] || 'find').to_s

        if finder == 'find'
          ***REMOVED*** an array of IDs may have been given:
          total_entries ||= (Array === args.first and args.first.size)
          ***REMOVED*** :all is implicit
          args.unshift(:all) if args.empty?
        end

        WillPaginate::Collection.create(page, per_page, total_entries) do |pager|
          count_options = options.except :page, :per_page, :total_entries, :finder
          find_options = count_options.except(:count).update(:offset => pager.offset, :limit => pager.per_page) 
          
          args << find_options
          ***REMOVED*** @options_from_last_find = nil
          pager.replace(send(finder, *args) { |*a| yield(*a) if block_given? })
          
          ***REMOVED*** magic counting for user convenience:
          pager.total_entries = wp_count(count_options, args, finder) unless pager.total_entries
        end
      end

      ***REMOVED*** Iterates through all records by loading one page at a time. This is useful
      ***REMOVED*** for migrations or any other use case where you don't want to load all the
      ***REMOVED*** records in memory at once.
      ***REMOVED***
      ***REMOVED*** It uses +paginate+ internally; therefore it accepts all of its options.
      ***REMOVED*** You can specify a starting page with <tt>:page</tt> (default is 1). Default
      ***REMOVED*** <tt>:order</tt> is <tt>"id"</tt>, override if necessary.
      ***REMOVED***
      ***REMOVED*** See {Faking Cursors in ActiveRecord}[http://weblog.jamisbuck.org/2007/4/6/faking-cursors-in-activerecord]
      ***REMOVED*** where Jamis Buck describes this and a more efficient way for MySQL.
      def paginated_each(options = {})
        options = { :order => 'id', :page => 1 }.merge options
        options[:page] = options[:page].to_i
        options[:total_entries] = 0 ***REMOVED*** skip the individual count queries
        total = 0
        
        begin 
          collection = paginate(options)
          with_exclusive_scope(:find => {}) do
            ***REMOVED*** using exclusive scope so that the block is yielded in scope-free context
            total += collection.each { |item| yield item }.size
          end
          options[:page] += 1
        end until collection.size < collection.per_page
        
        total
      end
      
      ***REMOVED*** Wraps +find_by_sql+ by simply adding LIMIT and OFFSET to your SQL string
      ***REMOVED*** based on the params otherwise used by paginating finds: +page+ and
      ***REMOVED*** +per_page+.
      ***REMOVED***
      ***REMOVED*** Example:
      ***REMOVED*** 
      ***REMOVED***   @developers = Developer.paginate_by_sql ['select * from developers where salary > ?', 80000],
      ***REMOVED***                          :page => params[:page], :per_page => 3
      ***REMOVED***
      ***REMOVED*** A query for counting rows will automatically be generated if you don't
      ***REMOVED*** supply <tt>:total_entries</tt>. If you experience problems with this
      ***REMOVED*** generated SQL, you might want to perform the count manually in your
      ***REMOVED*** application.
      ***REMOVED*** 
      def paginate_by_sql(sql, options)
        WillPaginate::Collection.create(*wp_parse_options(options)) do |pager|
          query = sanitize_sql(sql.dup)
          original_query = query.dup
          ***REMOVED*** add limit, offset
          add_limit! query, :offset => pager.offset, :limit => pager.per_page
          ***REMOVED*** perfom the find
          pager.replace find_by_sql(query)
          
          unless pager.total_entries
            count_query = original_query.sub /\bORDER\s+BY\s+[\w`,\s]+$/mi, ''
            count_query = "SELECT COUNT(*) FROM (***REMOVED***{count_query})"
            
            unless self.connection.adapter_name =~ /^(oracle|oci$)/i
              count_query << ' AS count_table'
            end
            ***REMOVED*** perform the count query
            pager.total_entries = count_by_sql(count_query)
          end
        end
      end

      def respond_to?(method, include_priv = false) ***REMOVED***:nodoc:
        case method.to_sym
        when :paginate, :paginate_by_sql
          true
        else
          super(method.to_s.sub(/^paginate/, 'find'), include_priv)
        end
      end

    protected
      
      def method_missing_with_paginate(method, *args) ***REMOVED***:nodoc:
        ***REMOVED*** did somebody tried to paginate? if not, let them be
        unless method.to_s.index('paginate') == 0
          if block_given?
            return method_missing_without_paginate(method, *args) { |*a| yield(*a) }
          else
            return method_missing_without_paginate(method, *args) 
          end
        end
        
        ***REMOVED*** paginate finders are really just find_* with limit and offset
        finder = method.to_s.sub('paginate', 'find')
        finder.sub!('find', 'find_all') if finder.index('find_by_') == 0
        
        options = args.pop
        raise ArgumentError, 'parameter hash expected' unless options.respond_to? :symbolize_keys
        options = options.dup
        options[:finder] = finder
        args << options
        
        paginate(*args) { |*a| yield(*a) if block_given? }
      end

      ***REMOVED*** Does the not-so-trivial job of finding out the total number of entries
      ***REMOVED*** in the database. It relies on the ActiveRecord +count+ method.
      def wp_count(options, args, finder)
        excludees = [:count, :order, :limit, :offset, :readonly]
        excludees << :from unless ActiveRecord::Calculations::CALCULATIONS_OPTIONS.include?(:from)

        ***REMOVED*** we may be in a model or an association proxy
        klass = (@owner and @reflection) ? @reflection.klass : self

        ***REMOVED*** Use :select from scope if it isn't already present.
        options[:select] = scope(:find, :select) unless options[:select]

        if options[:select] and options[:select] =~ /^\s*DISTINCT\b/i
          ***REMOVED*** Remove quoting and check for table_name.*-like statement.
          if options[:select].gsub('`', '') =~ /\w+\.\*/
            options[:select] = "DISTINCT ***REMOVED***{klass.table_name}.***REMOVED***{klass.primary_key}"
          end
        else
          excludees << :select ***REMOVED*** only exclude the select param if it doesn't begin with DISTINCT
        end

        ***REMOVED*** count expects (almost) the same options as find
        count_options = options.except *excludees

        ***REMOVED*** merge the hash found in :count
        ***REMOVED*** this allows you to specify :select, :order, or anything else just for the count query
        count_options.update options[:count] if options[:count]

        ***REMOVED*** forget about includes if they are irrelevant (Rails 2.1)
        if count_options[:include] and
            klass.private_methods.include_method?(:references_eager_loaded_tables?) and
            !klass.send(:references_eager_loaded_tables?, count_options)
          count_options.delete :include
        end

        ***REMOVED*** we may have to scope ...
        counter = Proc.new { count(count_options) }

        count = if finder.index('find_') == 0 and klass.respond_to?(scoper = finder.sub('find', 'with'))
                  ***REMOVED*** scope_out adds a 'with_finder' method which acts like with_scope, if it's present
                  ***REMOVED*** then execute the count with the scoping provided by the with_finder
                  send(scoper, &counter)
                elsif finder =~ /^find_(all_by|by)_([_a-zA-Z]\w*)$/
                  ***REMOVED*** extract conditions from calls like "paginate_by_foo_and_bar"
                  attribute_names = $2.split('_and_')
                  conditions = construct_attributes_from_arguments(attribute_names, args)
                  with_scope(:find => { :conditions => conditions }, &counter)
                else
                  counter.call
                end

        count.respond_to?(:length) ? count.length : count
      end

      def wp_parse_options(options) ***REMOVED***:nodoc:
        raise ArgumentError, 'parameter hash expected' unless options.respond_to? :symbolize_keys
        options = options.symbolize_keys
        raise ArgumentError, ':page parameter required' unless options.key? :page
        
        if options[:count] and options[:total_entries]
          raise ArgumentError, ':count and :total_entries are mutually exclusive'
        end

        page     = options[:page] || 1
        per_page = options[:per_page] || self.per_page
        total    = options[:total_entries]
        [page, per_page, total]
      end

    private

      ***REMOVED*** def find_every_with_paginate(options)
      ***REMOVED***   @options_from_last_find = options
      ***REMOVED***   find_every_without_paginate(options)
      ***REMOVED*** end
    end
  end
end
