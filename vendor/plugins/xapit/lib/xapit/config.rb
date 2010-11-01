module Xapit
  ***REMOVED*** Singleton class for storing Xapit configuration settings. Currently this only includes the database path.
  class Config
    class << self
      attr_reader :options
      
      ***REMOVED*** See Xapit***REMOVED***setup
      def setup(options = {})
        if @options && options[:database_path] != @options[:database_path]
          @database = nil
          @writable_database = nil
        end
        @options = options.reverse_merge(default_options)
      end
      
      def default_options
        {
          :indexer => SimpleIndexer,
          :query_parser => ClassicQueryParser,
          :spelling => true,
          :stemming => "english"
        }
      end
      
      ***REMOVED*** See if setup options are already set.
      def setup?
        @options
      end
      
      ***REMOVED*** The configured path to the database.
      def path
        @options[:database_path]
      end
      
      ***REMOVED*** Configure another database to use as a template.
      ***REMOVED*** It will copy this database to the database_path before attempting to open it.
      ***REMOVED*** This is very useful for testing since creating a database is slow.
      def template_path
        @options[:template_path]
      end
      
      def query_parser
        @options[:query_parser]
      end
      
      def indexer
        @options[:indexer]
      end
      
      def spelling?
        @options[:spelling]
      end
      
      def stemming
        @options[:stemming]
      end
      
      def breadcrumb_facets?
        @options[:breadcrumb_facets]
      end
      
      ***REMOVED*** Fetch Xapian::Database object at configured path. Database is stored in memory.
      def database
        @writable_database || (@database ||= Xapian::Database.new(path))
      end
      
      ***REMOVED*** Fetch Xapian::WritableDatabase object at configured path. Database is stored in memory.
      ***REMOVED*** Creates the database directory if needed.
      def writable_database
        @writable_database ||= generate_database
      end
      
      ***REMOVED*** Removes the configured database file and clears the stored one in memory.
      def remove_database
        FileUtils.rm_rf(path) if File.exist? File.join(path, "record.DB")
        @database = nil
        @writable_database = nil
      end
      
      ***REMOVED*** Clear the current database from memory. Unfortunately this is a hack because
      ***REMOVED*** Xapian doesn't provide a "close" method on the database. We just have to hope
      ***REMOVED*** no other references are lying around.
      ***REMOVED*** TODO looks like it does in 1.2, I should investigate and switch to that.
      def close_database
        @database = nil
        @writable_database = nil
        GC.start
      end
      
      private
      
      def generate_database
        FileUtils.mkdir_p(File.dirname(path)) unless File.exist?(File.dirname(path))
        FileUtils.cp_r(template_path, path) if template_path && !File.exist?(path)
        Xapian::WritableDatabase.new(path, Xapian::DB_CREATE_OR_OPEN)
      end
    end
  end
end
