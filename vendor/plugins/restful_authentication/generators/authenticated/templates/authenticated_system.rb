module AuthenticatedSystem
  protected
    ***REMOVED*** Returns true or false if the <%= file_name %> is logged in.
    ***REMOVED*** Preloads @current_<%= file_name %> with the <%= file_name %> model if they're logged in.
    def logged_in?
      !!current_<%= file_name %>
    end

    ***REMOVED*** Accesses the current <%= file_name %> from the session.
    ***REMOVED*** Future calls avoid the database because nil is not equal to false.
    def current_<%= file_name %>
      @current_<%= file_name %> ||= (login_from_session || login_from_basic_auth || login_from_cookie) unless @current_<%= file_name %> == false
    end

    ***REMOVED*** Store the given <%= file_name %> id in the session.
    def current_<%= file_name %>=(new_<%= file_name %>)
      session[:<%= file_name %>_id] = new_<%= file_name %> ? new_<%= file_name %>.id : nil
      @current_<%= file_name %> = new_<%= file_name %> || false
    end

    ***REMOVED*** Check if the <%= file_name %> is authorized
    ***REMOVED***
    ***REMOVED*** Override this method in your controllers if you want to restrict access
    ***REMOVED*** to only a few actions or if you want to check if the <%= file_name %>
    ***REMOVED*** has the correct rights.
    ***REMOVED***
    ***REMOVED*** Example:
    ***REMOVED***
    ***REMOVED***  ***REMOVED*** only allow nonbobs
    ***REMOVED***  def authorized?
    ***REMOVED***    current_<%= file_name %>.login != "bob"
    ***REMOVED***  end
    ***REMOVED***
    def authorized?(action = action_name, resource = nil)
      logged_in?
    end

    ***REMOVED*** Filter method to enforce a login requirement.
    ***REMOVED***
    ***REMOVED*** To require logins for all actions, use this in your controllers:
    ***REMOVED***
    ***REMOVED***   before_filter :login_required
    ***REMOVED***
    ***REMOVED*** To require logins for specific actions, use this in your controllers:
    ***REMOVED***
    ***REMOVED***   before_filter :login_required, :only => [ :edit, :update ]
    ***REMOVED***
    ***REMOVED*** To skip this in a subclassed controller:
    ***REMOVED***
    ***REMOVED***   skip_before_filter :login_required
    ***REMOVED***
    def login_required
      authorized? || access_denied
    end

    ***REMOVED*** Redirect as appropriate when an access request fails.
    ***REMOVED***
    ***REMOVED*** The default action is to redirect to the login screen.
    ***REMOVED***
    ***REMOVED*** Override this method in your controllers if you want to have special
    ***REMOVED*** behavior in case the <%= file_name %> is not authorized
    ***REMOVED*** to access the requested action.  For example, a popup window might
    ***REMOVED*** simply close itself.
    def access_denied
      respond_to do |format|
        format.html do
          store_location
          redirect_to new_<%= controller_routing_name %>_path
        end
        ***REMOVED*** format.any doesn't work in rails version < http://dev.rubyonrails.org/changeset/8987
        ***REMOVED*** Add any other API formats here.  (Some browsers, notably IE6, send Accept: */* and trigger 
        ***REMOVED*** the 'format.any' block incorrectly. See http://bit.ly/ie6_borken or http://bit.ly/ie6_borken2
        ***REMOVED*** for a workaround.)
        format.any(:json, :xml) do
          request_http_basic_authentication 'Web Password'
        end
      end
    end

    ***REMOVED*** Store the URI of the current request in the session.
    ***REMOVED***
    ***REMOVED*** We can return to this location by calling ***REMOVED***redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end

    ***REMOVED*** Redirect to the URI stored by the most recent store_location call or
    ***REMOVED*** to the passed default.  Set an appropriately modified
    ***REMOVED***   after_filter :store_location, :only => [:index, :new, :show, :edit]
    ***REMOVED*** for any controller you want to be bounce-backable.
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    ***REMOVED*** Inclusion hook to make ***REMOVED***current_<%= file_name %> and ***REMOVED***logged_in?
    ***REMOVED*** available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_<%= file_name %>, :logged_in?, :authorized? if base.respond_to? :helper_method
    end

    ***REMOVED***
    ***REMOVED*** Login
    ***REMOVED***

    ***REMOVED*** Called from ***REMOVED***current_<%= file_name %>.  First attempt to login by the <%= file_name %> id stored in the session.
    def login_from_session
      self.current_<%= file_name %> = <%= class_name %>.find_by_id(session[:<%= file_name %>_id]) if session[:<%= file_name %>_id]
    end

    ***REMOVED*** Called from ***REMOVED***current_<%= file_name %>.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |login, password|
        self.current_<%= file_name %> = <%= class_name %>.authenticate(login, password)
      end
    end
    
    ***REMOVED***
    ***REMOVED*** Logout
    ***REMOVED***

    ***REMOVED*** Called from ***REMOVED***current_<%= file_name %>.  Finaly, attempt to login by an expiring token in the cookie.
    ***REMOVED*** for the paranoid: we _should_ be storing <%= file_name %>_token = hash(cookie_token, request IP)
    def login_from_cookie
      <%= file_name %> = cookies[:auth_token] && <%= class_name %>.find_by_remember_token(cookies[:auth_token])
      if <%= file_name %> && <%= file_name %>.remember_token?
        self.current_<%= file_name %> = <%= file_name %>
        handle_remember_cookie! false ***REMOVED*** freshen cookie token (keeping date)
        self.current_<%= file_name %>
      end
    end

    ***REMOVED*** This is ususally what you want; resetting the session willy-nilly wreaks
    ***REMOVED*** havoc with forgery protection, and is only strictly necessary on login.
    ***REMOVED*** However, **all session state variables should be unset here**.
    def logout_keeping_session!
      ***REMOVED*** Kill server-side auth cookie
      @current_<%= file_name %>.forget_me if @current_<%= file_name %>.is_a? <%= class_name %>
      @current_<%= file_name %> = false     ***REMOVED*** not logged in, and don't do it for me
      kill_remember_cookie!     ***REMOVED*** Kill client-side auth cookie
      session[:<%= file_name %>_id] = nil   ***REMOVED*** keeps the session but kill our variable
      ***REMOVED*** explicitly kill any other session variables you set
    end

    ***REMOVED*** The session should only be reset at the tail end of a form POST --
    ***REMOVED*** otherwise the request forgery protection fails. It's only really necessary
    ***REMOVED*** when you cross quarantine (logged-out to logged-in).
    def logout_killing_session!
      logout_keeping_session!
      reset_session
    end
    
    ***REMOVED***
    ***REMOVED*** Remember_me Tokens
    ***REMOVED***
    ***REMOVED*** Cookies shouldn't be allowed to persist past their freshness date,
    ***REMOVED*** and they should be changed at each login

    ***REMOVED*** Cookies shouldn't be allowed to persist past their freshness date,
    ***REMOVED*** and they should be changed at each login

    def valid_remember_cookie?
      return nil unless @current_<%= file_name %>
      (@current_<%= file_name %>.remember_token?) && 
        (cookies[:auth_token] == @current_<%= file_name %>.remember_token)
    end
    
    ***REMOVED*** Refresh the cookie auth token if it exists, create it otherwise
    def handle_remember_cookie!(new_cookie_flag)
      return unless @current_<%= file_name %>
      case
      when valid_remember_cookie? then @current_<%= file_name %>.refresh_token ***REMOVED*** keeping same expiry date
      when new_cookie_flag        then @current_<%= file_name %>.remember_me 
      else                             @current_<%= file_name %>.forget_me
      end
      send_remember_cookie!
    end
  
    def kill_remember_cookie!
      cookies.delete :auth_token
    end
    
    def send_remember_cookie!
      cookies[:auth_token] = {
        :value   => @current_<%= file_name %>.remember_token,
        :expires => @current_<%= file_name %>.remember_token_expires_at }
    end

end
