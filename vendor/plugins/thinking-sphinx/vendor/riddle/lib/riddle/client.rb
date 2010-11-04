require 'riddle/client/filter'
require 'riddle/client/message'
require 'riddle/client/response'

module Riddle
  class VersionError < StandardError;  end
  class ResponseError < StandardError; end
  class OutOfBoundsError < StandardError; end
  
  ***REMOVED*** This class was heavily based on the existing Client API by Dmytro Shteflyuk
  ***REMOVED*** and Alexy Kovyrin. Their code worked fine, I just wanted something a bit
  ***REMOVED*** more Ruby-ish (ie. lowercase and underscored method names). I also have
  ***REMOVED*** used a few helper classes, just to neaten things up.
  ***REMOVED***
  ***REMOVED*** Feel free to use it wherever. Send bug reports, patches, comments and
  ***REMOVED*** suggestions to pat at freelancing-gods dot com.
  ***REMOVED***
  ***REMOVED*** Most properties of the client are accessible through attribute accessors,
  ***REMOVED*** and where relevant use symboles instead of the long constants common in
  ***REMOVED*** other clients.
  ***REMOVED*** Some examples:
  ***REMOVED***
  ***REMOVED***   client.sort_mode  = :extended
  ***REMOVED***   client.sort_by    = "birthday DESC"
  ***REMOVED***   client.match_mode = :extended
  ***REMOVED***
  ***REMOVED*** To add a filter, you will need to create a Filter object:
  ***REMOVED***
  ***REMOVED***   client.filters << Riddle::Client::Filter.new("birthday",
  ***REMOVED***     Time.at(1975, 1, 1).to_i..Time.at(1985, 1, 1).to_i, false)
  ***REMOVED***
  class Client
    Commands = {
      :search     => 0, ***REMOVED*** SEARCHD_COMMAND_SEARCH
      :excerpt    => 1, ***REMOVED*** SEARCHD_COMMAND_EXCERPT
      :update     => 2, ***REMOVED*** SEARCHD_COMMAND_UPDATE
      :keywords   => 3, ***REMOVED*** SEARCHD_COMMAND_KEYWORDS
      :persist    => 4, ***REMOVED*** SEARCHD_COMMAND_PERSIST
      :status     => 5, ***REMOVED*** SEARCHD_COMMAND_STATUS
      :query      => 6, ***REMOVED*** SEARCHD_COMMAND_QUERY
      :flushattrs => 7  ***REMOVED*** SEARCHD_COMMAND_FLUSHATTRS
    }
    
    Versions = {
      :search     => 0x113, ***REMOVED*** VER_COMMAND_SEARCH
      :excerpt    => 0x100, ***REMOVED*** VER_COMMAND_EXCERPT
      :update     => 0x101, ***REMOVED*** VER_COMMAND_UPDATE
      :keywords   => 0x100, ***REMOVED*** VER_COMMAND_KEYWORDS
      :status     => 0x100, ***REMOVED*** VER_COMMAND_STATUS
      :query      => 0x100, ***REMOVED*** VER_COMMAND_QUERY
      :flushattrs => 0x100  ***REMOVED*** VER_COMMAND_FLUSHATTRS
    }
    
    Statuses = {
      :ok      => 0, ***REMOVED*** SEARCHD_OK
      :error   => 1, ***REMOVED*** SEARCHD_ERROR
      :retry   => 2, ***REMOVED*** SEARCHD_RETRY
      :warning => 3  ***REMOVED*** SEARCHD_WARNING
    }
    
    MatchModes = {
      :all        => 0, ***REMOVED*** SPH_MATCH_ALL
      :any        => 1, ***REMOVED*** SPH_MATCH_ANY
      :phrase     => 2, ***REMOVED*** SPH_MATCH_PHRASE
      :boolean    => 3, ***REMOVED*** SPH_MATCH_BOOLEAN
      :extended   => 4, ***REMOVED*** SPH_MATCH_EXTENDED
      :fullscan   => 5, ***REMOVED*** SPH_MATCH_FULLSCAN
      :extended2  => 6  ***REMOVED*** SPH_MATCH_EXTENDED2
    }
    
    RankModes = {
      :proximity_bm25 => 0, ***REMOVED*** SPH_RANK_PROXIMITY_BM25
      :bm25           => 1, ***REMOVED*** SPH_RANK_BM25
      :none           => 2, ***REMOVED*** SPH_RANK_NONE
      :wordcount      => 3, ***REMOVED*** SPH_RANK_WORDCOUNT
      :proximity      => 4, ***REMOVED*** SPH_RANK_PROXIMITY
      :match_any      => 5, ***REMOVED*** SPH_RANK_MATCHANY
      :fieldmask      => 6, ***REMOVED*** SPH_RANK_FIELDMASK
      :sph04          => 7, ***REMOVED*** SPH_RANK_SPH04
      :total          => 8  ***REMOVED*** SPH_RANK_TOTAL
    }
    
    SortModes = {
      :relevance     => 0, ***REMOVED*** SPH_SORT_RELEVANCE
      :attr_desc     => 1, ***REMOVED*** SPH_SORT_ATTR_DESC
      :attr_asc      => 2, ***REMOVED*** SPH_SORT_ATTR_ASC
      :time_segments => 3, ***REMOVED*** SPH_SORT_TIME_SEGMENTS
      :extended      => 4, ***REMOVED*** SPH_SORT_EXTENDED
      :expr          => 5  ***REMOVED*** SPH_SORT_EXPR
    }
    
    AttributeTypes = {
      :integer    => 1, ***REMOVED*** SPH_ATTR_INTEGER
      :timestamp  => 2, ***REMOVED*** SPH_ATTR_TIMESTAMP
      :ordinal    => 3, ***REMOVED*** SPH_ATTR_ORDINAL
      :bool       => 4, ***REMOVED*** SPH_ATTR_BOOL
      :float      => 5, ***REMOVED*** SPH_ATTR_FLOAT
      :bigint     => 6, ***REMOVED*** SPH_ATTR_BIGINT
      :string     => 7, ***REMOVED*** SPH_ATTR_STRING
      :multi      => 0x40000000 ***REMOVED*** SPH_ATTR_MULTI
    }
    
    GroupFunctions = {
      :day      => 0, ***REMOVED*** SPH_GROUPBY_DAY
      :week     => 1, ***REMOVED*** SPH_GROUPBY_WEEK
      :month    => 2, ***REMOVED*** SPH_GROUPBY_MONTH
      :year     => 3, ***REMOVED*** SPH_GROUPBY_YEAR
      :attr     => 4, ***REMOVED*** SPH_GROUPBY_ATTR
      :attrpair => 5  ***REMOVED*** SPH_GROUPBY_ATTRPAIR
    }
    
    FilterTypes = {
      :values       => 0, ***REMOVED*** SPH_FILTER_VALUES
      :range        => 1, ***REMOVED*** SPH_FILTER_RANGE
      :float_range  => 2  ***REMOVED*** SPH_FILTER_FLOATRANGE
    }
    
    attr_accessor :servers, :port, :offset, :limit, :max_matches,
      :match_mode, :sort_mode, :sort_by, :weights, :id_range, :filters,
      :group_by, :group_function, :group_clause, :group_distinct, :cut_off,
      :retry_count, :retry_delay, :anchor, :index_weights, :rank_mode,
      :max_query_time, :field_weights, :timeout, :overrides, :select,
      :connection
    attr_reader :queue
    
    def self.connection=(value)
      Thread.current[:riddle_connection] = value
    end

    def self.connection
      Thread.current[:riddle_connection]
    end
    
    ***REMOVED*** Can instantiate with a specific server and port - otherwise it assumes
    ***REMOVED*** defaults of localhost and 3312 respectively. All other settings can be
    ***REMOVED*** accessed and changed via the attribute accessors.
    def initialize(servers=nil, port=nil)
      Riddle.version_warning
      
      @servers = (servers || ["localhost"] ).to_a.shuffle
      @port   = port     || 9312
      @socket = nil
      
      reset
      
      @queue = []
    end
    
    ***REMOVED*** Reset attributes and settings to defaults.
    def reset
      ***REMOVED*** defaults
      @offset         = 0
      @limit          = 20
      @max_matches    = 1000
      @match_mode     = :all
      @sort_mode      = :relevance
      @sort_by        = ''
      @weights        = []
      @id_range       = 0..0
      @filters        = []
      @group_by       = ''
      @group_function = :day
      @group_clause   = '@group desc'
      @group_distinct = ''
      @cut_off        = 0
      @retry_count    = 0
      @retry_delay    = 0
      @anchor         = {}
      ***REMOVED*** string keys are index names, integer values are weightings
      @index_weights  = {}
      @rank_mode      = :proximity_bm25
      @max_query_time = 0
      ***REMOVED*** string keys are field names, integer values are weightings
      @field_weights  = {}
      @timeout        = 0
      @overrides      = {}
      @select         = "*"
    end
    
    ***REMOVED*** The searchd server to query.  Servers are removed from @server after a
    ***REMOVED*** Timeout::Error is hit to allow for fail-over.
    def server
      @servers.first
    end

    ***REMOVED*** Backwards compatible writer to the @servers array.
    def server=(server)
      @servers = server.to_a
    end

    ***REMOVED*** Set the geo-anchor point - with the names of the attributes that contain
    ***REMOVED*** the latitude and longitude (in radians), and the reference position.
    ***REMOVED*** Note that for geocoding to work properly, you must also set
    ***REMOVED*** match_mode to :extended. To sort results by distance, you will
    ***REMOVED*** need to set sort_by to '@geodist asc', and sort_mode to extended (as an
    ***REMOVED*** example). Sphinx expects latitude and longitude to be returned from you
    ***REMOVED*** SQL source in radians.
    ***REMOVED***
    ***REMOVED*** Example:
    ***REMOVED***   client.set_anchor('lat', -0.6591741, 'long', 2.530770)
    ***REMOVED***
    def set_anchor(lat_attr, lat, long_attr, long)
      @anchor = {
        :latitude_attribute   => lat_attr,
        :latitude             => lat,
        :longitude_attribute  => long_attr,
        :longitude            => long
      }
    end
    
    ***REMOVED*** Append a query to the queue. This uses the same parameters as the query
    ***REMOVED*** method.
    def append_query(search, index = '*', comments = '')
      @queue << query_message(search, index, comments)
    end
    
    ***REMOVED*** Run all the queries currently in the queue. This will return an array of
    ***REMOVED*** results hashes.
    def run
      response = Response.new request(:search, @queue)
      
      results = @queue.collect do
        result = {
          :matches         => [],
          :fields          => [],
          :attributes      => {},
          :attribute_names => [],
          :words           => {}
        }

        result[:status] = response.next_int
        case result[:status]
        when Statuses[:warning]
          result[:warning] = response.next
        when Statuses[:error]
          result[:error] = response.next
          next result
        end
        
        result[:fields] = response.next_array

        attributes = response.next_int
        for i in 0...attributes
          attribute_name = response.next
          type           = response.next_int

          result[:attributes][attribute_name] = type
          result[:attribute_names] << attribute_name
        end

        matches   = response.next_int
        is_64_bit = response.next_int
        for i in 0...matches
          doc = is_64_bit > 0 ? response.next_64bit_int : response.next_int
          weight = response.next_int

          result[:matches] << {:doc => doc, :weight => weight, :index => i, :attributes => {}}
          result[:attribute_names].each do |attr|
            result[:matches].last[:attributes][attr] = attribute_from_type(
              result[:attributes][attr], response
            )
          end
        end

        result[:total] = response.next_int.to_i || 0
        result[:total_found] = response.next_int.to_i || 0
        result[:time] = ('%.3f' % (response.next_int / 1000.0)).to_f || 0.0

        words = response.next_int
        for i in 0...words
          word = response.next
          docs = response.next_int
          hits = response.next_int
          result[:words][word] = {:docs => docs, :hits => hits}
        end

        result
      end
      
      @queue.clear
      results
    end
    
    ***REMOVED*** Query the Sphinx daemon - defaulting to all indexes, but you can specify
    ***REMOVED*** a specific one if you wish. The search parameter should be a string
    ***REMOVED*** following Sphinx's expectations.
    ***REMOVED***
    ***REMOVED*** The object returned from this method is a hash with the following keys:
    ***REMOVED*** 
    ***REMOVED*** * :matches
    ***REMOVED*** * :fields
    ***REMOVED*** * :attributes
    ***REMOVED*** * :attribute_names
    ***REMOVED*** * :words
    ***REMOVED*** * :total
    ***REMOVED*** * :total_found
    ***REMOVED*** * :time
    ***REMOVED*** * :status
    ***REMOVED*** * :warning (if appropriate)
    ***REMOVED*** * :error (if appropriate)
    ***REMOVED***
    ***REMOVED*** The key <tt>:matches</tt> returns an array of hashes - the actual search
    ***REMOVED*** results. Each hash has the document id (<tt>:doc</tt>), the result 
    ***REMOVED*** weighting (<tt>:weight</tt>), and a hash of the attributes for the
    ***REMOVED*** document (<tt>:attributes</tt>).
    ***REMOVED*** 
    ***REMOVED*** The <tt>:fields</tt> and <tt>:attribute_names</tt> keys return list of
    ***REMOVED*** fields and attributes for the documents. The key <tt>:attributes</tt>
    ***REMOVED*** will return a hash of attribute name and type pairs, and <tt>:words</tt>
    ***REMOVED*** returns a hash of hashes representing the words from the search, with the
    ***REMOVED*** number of documents and hits for each, along the lines of:
    ***REMOVED*** 
    ***REMOVED***   results[:words]["Pat"] ***REMOVED***=> {:docs => 12, :hits => 15}
    ***REMOVED*** 
    ***REMOVED*** <tt>:total</tt>, <tt>:total_found</tt> and <tt>:time</tt> return the
    ***REMOVED*** number of matches available, the total number of matches (which may be
    ***REMOVED*** greater than the maximum available, depending on the number of matches
    ***REMOVED*** and your sphinx configuration), and the time in milliseconds that the
    ***REMOVED*** query took to run.
    ***REMOVED*** 
    ***REMOVED*** <tt>:status</tt> is the error code for the query - and if there was a
    ***REMOVED*** related warning, it will be under the <tt>:warning</tt> key. Fatal errors
    ***REMOVED*** will be described under <tt>:error</tt>.
    ***REMOVED***
    def query(search, index = '*', comments = '')
      @queue << query_message(search, index, comments)
      self.run.first
    end
    
    ***REMOVED*** Build excerpts from search terms (the +words+) and the text of documents. Excerpts are bodies of text that have the +words+ highlighted.
    ***REMOVED*** They may also be abbreviated to fit within a word limit.
    ***REMOVED***
    ***REMOVED*** As part of the options hash, you will need to
    ***REMOVED*** define:
    ***REMOVED*** * :docs
    ***REMOVED*** * :words
    ***REMOVED*** * :index
    ***REMOVED***
    ***REMOVED*** Optional settings include:
    ***REMOVED*** * :before_match (defaults to <span class="match">)
    ***REMOVED*** * :after_match (defaults to </span>)
    ***REMOVED*** * :chunk_separator (defaults to ' &***REMOVED***8230; ' - which is an HTML ellipsis)
    ***REMOVED*** * :limit (defaults to 256)
    ***REMOVED*** * :around (defaults to 5)
    ***REMOVED*** * :exact_phrase (defaults to false)
    ***REMOVED*** * :single_passage (defaults to false)
    ***REMOVED***
    ***REMOVED*** The defaults differ from the official PHP client, as I've opted for
    ***REMOVED*** semantic HTML markup.
    ***REMOVED***
    ***REMOVED*** Example:
    ***REMOVED***
    ***REMOVED***   client.excerpts(:docs => ["Pat Allan, Pat Cash"], :words => 'Pat', :index => 'pats')
    ***REMOVED***   ***REMOVED***=> ["<span class=\"match\">Pat</span> Allan, <span class=\"match\">Pat</span> Cash"]
    ***REMOVED***
    ***REMOVED***   lorem_lipsum = "Lorem ipsum dolor..."
    ***REMOVED***
    ***REMOVED***   client.excerpts(:docs => ["Pat Allan, ***REMOVED***{lorem_lipsum} Pat Cash"], :words => 'Pat', :index => 'pats')
    ***REMOVED***   ***REMOVED***=> ["<span class=\"match\">Pat</span> Allan, Lorem ipsum dolor sit amet, consectetur adipisicing
    ***REMOVED***          elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua &***REMOVED***8230; . Excepteur 
    ***REMOVED***          sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est 
    ***REMOVED***          laborum. <span class=\"match\">Pat</span> Cash"]  
    ***REMOVED***
    ***REMOVED*** Workflow:
    ***REMOVED***
    ***REMOVED*** Excerpt creation is completely isolated from searching the index. The nominated index is only used to 
    ***REMOVED*** discover encoding and charset information.
    ***REMOVED***
    ***REMOVED*** Therefore, the workflow goes:
    ***REMOVED***
    ***REMOVED*** 1. Do the sphinx query.
    ***REMOVED*** 2. Fetch the documents found by sphinx from their repositories.
    ***REMOVED*** 3. Pass the documents' text to +excerpts+ for marking up of matched terms.
    ***REMOVED***
    def excerpts(options = {})
      options[:index]            ||= '*'
      options[:before_match]     ||= '<span class="match">'
      options[:after_match]      ||= '</span>'
      options[:chunk_separator]  ||= ' &***REMOVED***8230; ' ***REMOVED*** ellipsis
      options[:limit]            ||= 256
      options[:limit_passages]   ||= 0
      options[:limit_words]      ||= 0
      options[:around]           ||= 5
      options[:exact_phrase]     ||= false
      options[:single_passage]   ||= false
      options[:query_mode]       ||= false
      options[:force_all_words]  ||= false
      options[:start_passage_id] ||= 1
      options[:load_files]       ||= false
      options[:html_strip_mode]  ||= 'index'
      options[:allow_empty]      ||= false
      
      response = Response.new request(:excerpt, excerpts_message(options))
      
      options[:docs].collect { response.next }
    end
    
    ***REMOVED*** Update attributes - first parameter is the relevant index, second is an
    ***REMOVED*** array of attributes to be updated, and the third is a hash, where the
    ***REMOVED*** keys are the document ids, and the values are arrays with the attribute
    ***REMOVED*** values - in the same order as the second parameter.
    ***REMOVED***
    ***REMOVED*** Example:
    ***REMOVED*** 
    ***REMOVED***   client.update('people', ['birthday'], {1 => [Time.at(1982, 20, 8).to_i]})
    ***REMOVED*** 
    def update(index, attributes, values_by_doc)
      response = Response.new request(
        :update,
        update_message(index, attributes, values_by_doc)
      )
      
      response.next_int
    end
    
    ***REMOVED*** Generates a keyword list for a given query. Each keyword is represented
    ***REMOVED*** by a hash, with keys :tokenised and :normalised. If return_hits is set to
    ***REMOVED*** true it will also report on the number of hits and documents for each
    ***REMOVED*** keyword (see :hits and :docs keys respectively).
    def keywords(query, index, return_hits = false)
      response = Response.new request(
        :keywords,
        keywords_message(query, index, return_hits)
      )
      
      (0...response.next_int).collect do
        hash = {}
        hash[:tokenised]  = response.next
        hash[:normalised] = response.next
        
        if return_hits
          hash[:docs] = response.next_int
          hash[:hits] = response.next_int
        end
        
        hash
      end
    end
    
    def status
      response = Response.new request(
        :status, Message.new
      )
      
      rows, cols = response.next_int, response.next_int
      
      (0...rows).inject({}) do |hash, row|
        hash[response.next.to_sym] = response.next
        hash
      end
    end
    
    def flush_attributes
      response = Response.new request(
        :flushattrs, Message.new
      )
      
      response.next_int
    end
    
    def add_override(attribute, type, values)
      @overrides[attribute] = {:type => type, :values => values}
    end
    
    def open
      open_socket
      
      return if Versions[:search] < 0x116
      
      @socket.send [
        Commands[:persist], 0, 4, 1
      ].pack("nnNN"), 0
    end
    
    def close
      close_socket
    end
    
    private
    
    def open_socket
      raise "Already Connected" unless @socket.nil?
      
      if @timeout == 0
        @socket = initialise_connection
      else
        begin
          Timeout.timeout(@timeout) { @socket = initialise_connection }
        rescue Timeout::Error, Riddle::ConnectionError => e
          failed_servers ||= []
          failed_servers << servers.shift
          retry if !servers.empty?

          case e
          when Timeout::Error
            raise Riddle::ConnectionError,
              "Connection to ***REMOVED***{failed_servers.inspect} on ***REMOVED***{@port} timed out after ***REMOVED***{@timeout} seconds"
          else
            raise e
          end
        end
      end
      
      true
    end
    
    def close_socket
      raise "Not Connected" if @socket.nil?
      
      @socket.close
      @socket = nil
      
      true
    end
    
    ***REMOVED*** Connects to the Sphinx daemon, and yields a socket to use. The socket is
    ***REMOVED*** closed at the end of the block.
    def connect(&block)
      if @socket.nil? || @socket.closed?
        @socket = nil
        open_socket
        begin
          yield @socket
        ensure
          close_socket
        end
      else
        yield @socket
      end
    end
    
    def initialise_connection
      socket = initialise_socket
      
      ***REMOVED*** Checking version
      version = socket.recv(4).unpack('N*').first
      if version < 1
        socket.close
        raise VersionError, "Can only connect to searchd version 1.0 or better, not version ***REMOVED***{version}"
      end
      
      ***REMOVED*** Send version
      socket.send [1].pack('N'), 0
      
      socket
    end
    
    def initialise_socket
      tries = 0
      begin
        socket = if self.connection
          self.connection.call(self)
        elsif self.class.connection
          self.class.connection.call(self)
        elsif server.index('/') == 0
          UNIXSocket.new server
        else
          TCPSocket.new server, @port
        end
      rescue Errno::ECONNREFUSED => e
        retry if (tries += 1) < 5
        raise Riddle::ConnectionError,
          "Connection to ***REMOVED***{server} on ***REMOVED***{@port} failed. ***REMOVED***{e.message}"
      end
      
      socket
    end
    
    ***REMOVED*** Send a collection of messages, for a command type (eg, search, excerpts,
    ***REMOVED*** update), to the Sphinx daemon.
    def request(command, messages)
      response = ""
      status   = -1
      version  = 0
      length   = 0
      message  = Array(messages).join("")
      if message.respond_to?(:force_encoding)
        message = message.force_encoding('ASCII-8BIT')
      end
      
      connect do |socket|
        case command
        when :search
          ***REMOVED*** Message length is +4 to account for the following count value for
          ***REMOVED*** the number of messages (well, that's what I'm assuming).
          socket.send [
            Commands[command], Versions[command],
            4+message.length,  messages.length
          ].pack("nnNN") + message, 0
        when :status
          socket.send [
            Commands[command], Versions[command], 4, 1
          ].pack("nnNN"), 0
        else
          socket.send [
            Commands[command], Versions[command], message.length
          ].pack("nnN") + message, 0
        end
        
        header = socket.recv(8)
        status, version, length = header.unpack('n2N')
        
        while response.length < (length || 0)
          part = socket.recv(length - response.length)
          response << part if part
        end
      end
      
      if response.empty? || response.length != length
        raise ResponseError, "No response from searchd (status: ***REMOVED***{status}, version: ***REMOVED***{version})"
      end
      
      case status
      when Statuses[:ok]
        if version < Versions[command]
          puts format("searchd command v.%d.%d older than client (v.%d.%d)",
            version >> 8, version & 0xff,
            Versions[command] >> 8, Versions[command] & 0xff)
        end
        response
      when Statuses[:warning]
        length = response[0, 4].unpack('N*').first
        puts response[4, length]
        response[4 + length, response.length - 4 - length]
      when Statuses[:error], Statuses[:retry]
        message = response[4, response.length - 4]
        klass = message[/out of bounds/] ? OutOfBoundsError : ResponseError
        raise klass, "searchd error (status: ***REMOVED***{status}): ***REMOVED***{message}"
      else
        raise ResponseError, "Unknown searchd error (status: ***REMOVED***{status})"
      end
    end
    
    ***REMOVED*** Generation of the message to send to Sphinx for a search.
    def query_message(search, index, comments = '')
      message = Message.new
      
      ***REMOVED*** Mode, Limits, Sort Mode
      message.append_ints @offset, @limit, MatchModes[@match_mode],
        RankModes[@rank_mode], SortModes[@sort_mode]
      message.append_string @sort_by
      
      ***REMOVED*** Query
      message.append_string search
      
      ***REMOVED*** Weights
      message.append_int @weights.length
      message.append_ints *@weights
      
      ***REMOVED*** Index
      message.append_string index
      
      ***REMOVED*** ID Range
      message.append_int 1
      message.append_64bit_ints @id_range.first, @id_range.last
      
      ***REMOVED*** Filters
      message.append_int @filters.length
      @filters.each { |filter| message.append filter.query_message }
      
      ***REMOVED*** Grouping
      message.append_int GroupFunctions[@group_function]
      message.append_string @group_by
      message.append_int @max_matches
      message.append_string @group_clause
      message.append_ints @cut_off, @retry_count, @retry_delay
      message.append_string @group_distinct
      
      ***REMOVED*** Anchor Point
      if @anchor.empty?
        message.append_int 0
      else
        message.append_int 1
        message.append_string @anchor[:latitude_attribute]
        message.append_string @anchor[:longitude_attribute]
        message.append_floats @anchor[:latitude], @anchor[:longitude]
      end
      
      ***REMOVED*** Per Index Weights
      message.append_int @index_weights.length
      @index_weights.each do |key,val|
        message.append_string key.to_s
        message.append_int val
      end
      
      ***REMOVED*** Max Query Time
      message.append_int @max_query_time
      
      ***REMOVED*** Per Field Weights
      message.append_int @field_weights.length
      @field_weights.each do |key,val|
        message.append_string key.to_s
        message.append_int val
      end
      
      message.append_string comments
      
      return message.to_s if Versions[:search] < 0x116
      
      ***REMOVED*** Overrides  
      message.append_int @overrides.length
      @overrides.each do |key,val|
        message.append_string key.to_s
        message.append_int AttributeTypes[val[:type]]
        message.append_int val[:values].length
        val[:values].each do |id,map|
          message.append_64bit_int id
          method = case val[:type]
          when :float
            :append_float
          when :bigint
            :append_64bit_int
          else
            :append_int
          end
          message.send method, map
        end
      end
      
      message.append_string @select
      
      message.to_s
    end
    
    ***REMOVED*** Generation of the message to send to Sphinx for an excerpts request.
    def excerpts_message(options)
      message = Message.new
      
      message.append [0, excerpt_flags(options)].pack('N2') ***REMOVED*** 0 = mode
      message.append_string options[:index]
      message.append_string options[:words]
      
      ***REMOVED*** options
      message.append_string options[:before_match]
      message.append_string options[:after_match]
      message.append_string options[:chunk_separator]
      message.append_ints options[:limit], options[:around]
      
      message.append_array options[:docs]
      
      message.to_s
    end
    
    ***REMOVED*** Generation of the message to send to Sphinx to update attributes of a
    ***REMOVED*** document.
    def update_message(index, attributes, values_by_doc)
      message = Message.new
      
      message.append_string index
      message.append_array attributes
      
      message.append_int values_by_doc.length
      values_by_doc.each do |key,values|
        message.append_64bit_int key ***REMOVED*** document ID
        message.append_ints *values ***REMOVED*** array of new values (integers)
      end
      
      message.to_s
    end
    
    ***REMOVED*** Generates the simple message to send to the daemon for a keywords request.
    def keywords_message(query, index, return_hits)
      message = Message.new
      
      message.append_string query
      message.append_string index
      message.append_int return_hits ? 1 : 0
      
      message.to_s
    end
    
    def attribute_from_type(type, response)
      type -= AttributeTypes[:multi] if is_multi = type > AttributeTypes[:multi]
      
      case type
      when AttributeTypes[:float]
        is_multi ? response.next_float_array    : response.next_float
      when AttributeTypes[:bigint]
        is_multi ? response.next_64bit_int_arry : response.next_64bit_int
      when AttributeTypes[:string]
        is_multi ? response.next_array          : response.next
      else
        is_multi ? response.next_int_array      : response.next_int
      end
    end
    
    def excerpt_flags(options)
      flags = 1
      flags |= 2   if options[:exact_phrase]
      flags |= 4   if options[:single_passage]
      flags |= 8   if options[:use_boundaries]
      flags |= 16  if options[:weight_order]
      flags |= 32  if options[:query_mode]
      flags |= 64  if options[:force_all_words]
      flags |= 128 if options[:load_files]
      flags |= 256 if options[:allow_empty]
      flags
    end
  end
end
