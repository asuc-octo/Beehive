module AuthenticatedSystem
  protected
    ***REMOVED*** Returns true or false if the user is logged in.
    ***REMOVED*** Preloads @current_user with the user model if they're logged in.
    def logged_in?
      !!current_user
    end

    ***REMOVED*** Accesses the current user from the session.
    ***REMOVED*** Future calls avoid the database because nil is not equal to false.
    def current_user
      @current_user ||= (login_from_session || login_from_basic_auth || login_from_cookie) unless @current_user == false
    end

    ***REMOVED*** Store the given user id in the session.
    def current_user=(new_user)
      session[:user_id] = new_user ? new_user.id : nil
      @current_user = new_user || false
    end

    ***REMOVED*** Check if the user is authorized
    ***REMOVED***
    ***REMOVED*** Override this method in your controllers if you want to restrict access
    ***REMOVED*** to only a few actions or if you want to check if the user
    ***REMOVED*** has the correct rights.
    ***REMOVED***
    ***REMOVED*** Example:
    ***REMOVED***
    ***REMOVED***  ***REMOVED*** only allow nonbobs
    ***REMOVED***  def authorized?
    ***REMOVED***    current_user.login != "bob"
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
    ***REMOVED*** behavior in case the user is not authorized
    ***REMOVED*** to access the requested action.  For example, a popup window might
    ***REMOVED*** simply close itself.
    def access_denied
      respond_to do |format|
        format.html do
          store_location
          redirect_to new_session_path
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

    ***REMOVED*** Inclusion hook to make ***REMOVED***current_user and ***REMOVED***logged_in?
    ***REMOVED*** available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?, :authorized? if base.respond_to? :helper_method
    end

    ***REMOVED***
    ***REMOVED*** Login
    ***REMOVED***

    ***REMOVED*** Called from ***REMOVED***current_user.  First attempt to login by the user id stored in the session.
    def login_from_session
      self.current_user = User.find_by_id(session[:user_id]) if session[:user_id]
    end

    ***REMOVED*** Called from ***REMOVED***current_user.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |login, password|
        self.current_user = User.authenticate(login, password)
      end
    end
    
    ***REMOVED***
    ***REMOVED*** Logout
    ***REMOVED***

    ***REMOVED*** Called from ***REMOVED***current_user.  Finaly, attempt to login by an expiring token in the cookie.
    ***REMOVED*** for the paranoid: we _should_ be storing user_token = hash(cookie_token, request IP)
    def login_from_cookie
      user = cookies[:auth_token] && User.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        self.current_user = user
        handle_remember_cookie! false ***REMOVED*** freshen cookie token (keeping date)
        self.current_user
      end
    end

    ***REMOVED*** This is ususally what you want; resetting the session willy-nilly wreaks
    ***REMOVED*** havoc with forgery protection, and is only strictly necessary on login.
    ***REMOVED*** However, **all session state variables should be unset here**.
    def logout_keeping_session!
      ***REMOVED*** Kill server-side auth cookie
      @current_user.forget_me if @current_user.is_a? User
      @current_user = false     ***REMOVED*** not logged in, and don't do it for me
      kill_remember_cookie!     ***REMOVED*** Kill client-side auth cookie
      session[:user_id] = nil   ***REMOVED*** keeps the session but kill our variable
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
      return nil unless @current_user
      (@current_user.remember_token?) && 
        (cookies[:auth_token] == @current_user.remember_token)
    end
    
    ***REMOVED*** Refresh the cookie auth token if it exists, create it otherwise
    def handle_remember_cookie!(new_cookie_flag)
      return unless @current_user
      case
      when valid_remember_cookie? then @current_user.refresh_token ***REMOVED*** keeping same expiry date
      when new_cookie_flag        then @current_user.remember_me 
      else                             @current_user.forget_me
      end
      send_remember_cookie!
    end
  
    def kill_remember_cookie!
      cookies.delete :auth_token
    end
    
    def send_remember_cookie!
      cookies[:auth_token] = {
        :value   => @current_user.remember_token,
        :expires => @current_user.remember_token_expires_at }
    end

end
