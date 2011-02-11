module CASClient
  module Frameworks
    module Merb
      module Filter
        attr_reader :client

        def cas_filter
          @client ||= CASClient::Client.new(config)

          service_ticket = read_ticket(self)

          cas_login_url = client.add_service_to_login_url(read_service_url(self))

          last_service_ticket = session[:cas_last_valid_ticket]
          if (service_ticket && last_service_ticket && 
              last_service_ticket.ticket == service_ticket.ticket && 
              last_service_ticket.service == service_ticket.service)

            ***REMOVED*** warn() rather than info() because we really shouldn't be re-validating the same ticket. 
            ***REMOVED*** The only time when this is acceptable is if the user manually does a refresh and the ticket
            ***REMOVED*** happens to be in the URL.
            log.warn("Reusing previously validated ticket since the new ticket and service are the same.")
            service_ticket = last_service_ticket
          elsif last_service_ticket &&
            !config[:authenticate_on_every_request] && 
            session[client.username_session_key]
            ***REMOVED*** Re-use the previous ticket if the user already has a local CAS session (i.e. if they were already
            ***REMOVED*** previously authenticated for this service). This is to prevent redirection to the CAS server on every
            ***REMOVED*** request.
            ***REMOVED*** This behaviour can be disabled (so that every request is routed through the CAS server) by setting
            ***REMOVED*** the :authenticate_on_every_request config option to false. 
            log.debug "Existing local CAS session detected for ***REMOVED***{session[client.username_session_key].inspect}. "+
              "Previous ticket ***REMOVED***{last_service_ticket.ticket.inspect} will be re-used."
              service_ticket = last_service_ticket
          end

          if service_ticket
            client.validate_service_ticket(service_ticket) unless service_ticket.has_been_validated?
            validation_response = service_ticket.response

            if service_ticket.is_valid?
              log.info("Ticket ***REMOVED***{service_ticket.inspect} for service ***REMOVED***{service_ticket.service.inspect} " + 
                "belonging to user ***REMOVED***{validation_response.user.inspect} is VALID.")

              session[client.username_session_key] = validation_response.user
              session[client.extra_attributes_session_key] = validation_response.extra_attributes

              ***REMOVED*** Store the ticket in the session to avoid re-validating the same service
              ***REMOVED*** ticket with the CAS server.
              session[:cas_last_valid_ticket] = service_ticket
              return true
            else  
              log.warn("Ticket ***REMOVED***{service_ticket.ticket.inspect} failed validation -- " + 
                "***REMOVED***{validation_response.failure_code}: ***REMOVED***{validation_response.failure_message}")
              redirect cas_login_url
              throw :halt
            end
          else
            log.warn("No ticket -- redirecting to ***REMOVED***{cas_login_url}")
            redirect cas_login_url
            throw :halt
          end
        end

        private
        ***REMOVED*** Copied from Rails adapter
        def read_ticket(controller)
          ticket = controller.params[:ticket]

          return nil unless ticket

          log.debug("Request contains ticket ***REMOVED***{ticket.inspect}.")

          if ticket =~ /^PT-/
            ProxyTicket.new(ticket, read_service_url(controller), controller.params[:renew])
          else
            ServiceTicket.new(ticket, read_service_url(controller), controller.params[:renew])
          end
        end

        ***REMOVED*** Also copied from Rails adapter
        def read_service_url(controller)
          if config[:service_url]
            log.debug("Using explicitly set service url: ***REMOVED***{config[:service_url]}")
            return config[:service_url]
          end

          params = controller.params.dup
          params.delete(:ticket)
          service_url = request.protocol + '://' + request.host / controller.url(params.to_hash.symbolize_keys!)
          log.debug("Guessed service url: ***REMOVED***{service_url.inspect}")
          return service_url
        end

        def log
          ::Merb.logger
        end

        def config
          ::Merb::Plugins.config[:"rubycas-client"]
        end
      end
    end
  end
end
