module CASClient
  ***REMOVED*** The client brokers all HTTP transactions with the CAS server.
  class Client
    attr_reader :cas_base_url 
    attr_reader :log, :username_session_key, :extra_attributes_session_key
    attr_writer :login_url, :validate_url, :proxy_url, :logout_url, :service_url
    attr_accessor :proxy_callback_url, :proxy_retrieval_url
    
    def initialize(conf = nil)
      configure(conf) if conf
    end
    
    def configure(conf)
      ***REMOVED***TODO: raise error if conf contains unrecognized cas options (this would help detect user typos in the config)

      raise ArgumentError, "Missing :cas_base_url parameter!" unless conf[:cas_base_url]
      
      @cas_base_url      = conf[:cas_base_url].gsub(/\/$/, '')       
      
      @login_url    = conf[:login_url]
      @logout_url   = conf[:logout_url]
      @validate_url = conf[:validate_url]
      @proxy_url    = conf[:proxy_url]
      @service_url  = conf[:service_url]
      @force_ssl_verification  = conf[:force_ssl_verification]
      @proxy_callback_url  = conf[:proxy_callback_url]
      @proxy_retrieval_url = conf[:proxy_retrieval_url]
      
      @username_session_key         = conf[:username_session_key] || :cas_user
      @extra_attributes_session_key = conf[:extra_attributes_session_key] || :cas_extra_attributes
      
      @log = CASClient::LoggerWrapper.new
      @log.set_real_logger(conf[:logger]) if conf[:logger]
    end
    
    def login_url
      @login_url || (cas_base_url + "/login")
    end
    
    def validate_url
      @validate_url || (cas_base_url + "/proxyValidate")
    end
    
    ***REMOVED*** Returns the CAS server's logout url.
    ***REMOVED***
    ***REMOVED*** If a logout_url has not been explicitly configured,
    ***REMOVED*** the default is cas_base_url + "/logout".
    ***REMOVED***
    ***REMOVED*** destination_url:: Set this if you want the user to be
    ***REMOVED***                   able to immediately log back in. Generally
    ***REMOVED***                   you'll want to use something like <tt>request.referer</tt>.
    ***REMOVED***                   Note that the above behaviour describes RubyCAS-Server 
    ***REMOVED***                   -- other CAS server implementations might use this
    ***REMOVED***                   parameter differently (or not at all).
    ***REMOVED*** follow_url:: This satisfies section 2.3.1 of the CAS protocol spec.
    ***REMOVED***              See http://www.ja-sig.org/products/cas/overview/protocol
    def logout_url(destination_url = nil, follow_url = nil)
      url = @logout_url || (cas_base_url + "/logout")
      
      if destination_url
        ***REMOVED*** if present, remove the 'ticket' parameter from the destination_url
        duri = URI.parse(destination_url)
        h = duri.query ? query_to_hash(duri.query) : {}
        h.delete('ticket')
        duri.query = hash_to_query(h)
        destination_url = duri.to_s.gsub(/\?$/, '')
      end
      
      if destination_url || follow_url
        uri = URI.parse(url)
        h = uri.query ? query_to_hash(uri.query) : {}
        h['destination'] = destination_url if destination_url
        h['url'] = follow_url if follow_url
        uri.query = hash_to_query(h)
        uri.to_s
      else
        url
      end
    end
    
    def proxy_url
      @proxy_url || (cas_base_url + "/proxy")
    end
    
    def validate_service_ticket(st)
      uri = URI.parse(validate_url)
      h = uri.query ? query_to_hash(uri.query) : {}
      h['service'] = st.service
      h['ticket'] = st.ticket
      h['renew'] = 1 if st.renew
      h['pgtUrl'] = proxy_callback_url if proxy_callback_url
      uri.query = hash_to_query(h)
      
      st.response = request_cas_response(uri, ValidationResponse)
      
      return st
    end
    alias validate_proxy_ticket validate_service_ticket
    
    ***REMOVED*** Returns true if the configured CAS server is up and responding;
    ***REMOVED*** false otherwise.
    def cas_server_is_up?
      uri = URI.parse(login_url)
      
      log.debug "Checking if CAS server at URI '***REMOVED***{uri}' is up..."
      
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = (uri.scheme == 'https')
      https.verify_mode = (@force_ssl_verification ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE)
      
      begin
        raw_res = https.start do |conn|
          conn.get("***REMOVED***{uri.path}?***REMOVED***{uri.query}")
        end
      rescue Errno::ECONNREFUSED => e
        log.warn "CAS server did not respond! (***REMOVED***{e.inspect})"
        return false
      end
      
      log.debug "CAS server responded with ***REMOVED***{raw_res.inspect}:\n***REMOVED***{raw_res.body}"
      
      return raw_res.kind_of?(Net::HTTPSuccess)
    end
    
    ***REMOVED*** Requests a login using the given credentials for the given service; 
    ***REMOVED*** returns a LoginResponse object.
    def login_to_service(credentials, service)
      lt = request_login_ticket
      
      data = credentials.merge(
        :lt => lt,
        :service => service 
      )
      
      res = submit_data_to_cas(login_url, data)
      response = CASClient::LoginResponse.new(res)

      if response.is_success?
        log.info("Login was successful for ticket: ***REMOVED***{response.ticket.inspect}.")
      end

      return response
    end
  
    ***REMOVED*** Requests a login ticket from the CAS server for use in a login request;
    ***REMOVED*** returns a LoginTicket object.
    ***REMOVED***
    ***REMOVED*** This only works with RubyCAS-Server, since obtaining login
    ***REMOVED*** tickets in this manner is not part of the official CAS spec.
    def request_login_ticket
      uri = URI.parse(login_url+'Ticket')
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = (uri.scheme == 'https')
      https.verify_mode = (@force_ssl_verification ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE)
      res = https.post(uri.path, ';')
      
      raise CASException, res.body unless res.kind_of? Net::HTTPSuccess
      
      res.body.strip
    end
    
    ***REMOVED*** Requests a proxy ticket from the CAS server for the given service
    ***REMOVED*** using the given pgt (proxy granting ticket); returns a ProxyTicket 
    ***REMOVED*** object.
    ***REMOVED***
    ***REMOVED*** The pgt required to request a proxy ticket is obtained as part of
    ***REMOVED*** a ValidationResponse.
    def request_proxy_ticket(pgt, target_service)
      uri = URI.parse(proxy_url)
      h = uri.query ? query_to_hash(uri.query) : {}
      h['pgt'] = pgt.ticket
      h['targetService'] = target_service
      uri.query = hash_to_query(h)
      
      pr = request_cas_response(uri, ProxyResponse)
      
      pt = ProxyTicket.new(pr.proxy_ticket, target_service)
      pt.response = pr
      
      return pt
    end
    
    def retrieve_proxy_granting_ticket(pgt_iou)
      uri = URI.parse(proxy_retrieval_url)
      uri.query = (uri.query ? uri.query + "&" : "") + "pgtIou=***REMOVED***{CGI.escape(pgt_iou)}"
      retrieve_url = uri.to_s
      
      log.debug "Retrieving PGT for PGT IOU ***REMOVED***{pgt_iou.inspect} from ***REMOVED***{retrieve_url.inspect}"
      
***REMOVED***      https = Net::HTTP.new(uri.host, uri.port)
***REMOVED***      https.use_ssl = (uri.scheme == 'https')
***REMOVED***      res = https.post(uri.path, ';')
      uri = URI.parse(uri) unless uri.kind_of? URI
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = (uri.scheme == 'https')
      https.verify_mode = (@force_ssl_verification ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE)
      
      res = https.start do |conn|
        conn.get("***REMOVED***{uri.path}?***REMOVED***{uri.query}")
      end
      
      
      raise CASException, res.body unless res.kind_of? Net::HTTPSuccess
      
      ProxyGrantingTicket.new(res.body.strip, pgt_iou)
    end
    
    def add_service_to_login_url(service_url)
      uri = URI.parse(login_url)
      uri.query = (uri.query ? uri.query + "&" : "") + "service=***REMOVED***{CGI.escape(service_url)}"
      uri.to_s
    end
    
    private
    ***REMOVED*** Fetches a CAS response of the given type from the given URI.
    ***REMOVED*** Type should be either ValidationResponse or ProxyResponse.
    def request_cas_response(uri, type)
      log.debug "Requesting CAS response for URI ***REMOVED***{uri}"
      
      uri = URI.parse(uri) unless uri.kind_of? URI
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = (uri.scheme == 'https')
      https.verify_mode = (@force_ssl_verification ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE)
      
      begin
        raw_res = https.start do |conn|
          conn.get("***REMOVED***{uri.path}?***REMOVED***{uri.query}")
        end
      rescue Errno::ECONNREFUSED => e
        log.error "CAS server did not respond! (***REMOVED***{e.inspect})"
        raise "The CAS authentication server at ***REMOVED***{uri} is not responding!"
      end
      
      ***REMOVED*** We accept responses of type 422 since RubyCAS-Server generates these
      ***REMOVED*** in response to requests from the client that are processable but contain
      ***REMOVED*** invalid CAS data (for example an invalid service ticket).
      if raw_res.kind_of?(Net::HTTPSuccess) || raw_res.code.to_i == 422
        log.debug "CAS server responded with ***REMOVED***{raw_res.inspect}:\n***REMOVED***{raw_res.body}"
      else
        log.error "CAS server responded with an error! (***REMOVED***{raw_res.inspect})"
        raise "The CAS authentication server at ***REMOVED***{uri} responded with an error (***REMOVED***{raw_res.inspect})!"
      end
      
      type.new(raw_res.body)
    end
    
    ***REMOVED*** Submits some data to the given URI and returns a Net::HTTPResponse.
    def submit_data_to_cas(uri, data)
      uri = URI.parse(uri) unless uri.kind_of? URI
      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data(data, ';')
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = (uri.scheme == 'https')
      https.verify_mode = (@force_ssl_verification ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE)
      https.start {|conn| conn.request(req) }
    end
    
    def query_to_hash(query)
      CGI.parse(query)
    end
      
    def hash_to_query(hash)
      pairs = []
      hash.each do |k, vals|
        vals = [vals] unless vals.kind_of? Array
        vals.each {|v| pairs << (v.nil? ? CGI.escape(k) : "***REMOVED***{CGI.escape(k)}=***REMOVED***{CGI.escape(v)}")}
      end
      pairs.join("&")
    end
  end
end
