***REMOVED*** -*- coding: utf-8 -*-
module Authentication
  module ByCookieToken
    ***REMOVED*** Stuff directives into including module 
    def self.included(recipient)
      recipient.extend(ModelClassMethods)
      recipient.class_eval do
        include ModelInstanceMethods
      end
    end

    ***REMOVED***
    ***REMOVED*** Class Methods
    ***REMOVED***
    module ModelClassMethods
    end ***REMOVED*** class methods

    ***REMOVED***
    ***REMOVED*** Instance Methods
    ***REMOVED***
    module ModelInstanceMethods
      def remember_token?
        (!remember_token.blank?) && 
          remember_token_expires_at && (Time.now.utc < remember_token_expires_at.utc)
      end

      ***REMOVED*** These create and unset the fields required for remembering users between browser closes
      def remember_me
        remember_me_for 2.weeks
      end

      def remember_me_for(time)
        remember_me_until time.from_now.utc
      end

      def remember_me_until(time)
        self.remember_token_expires_at = time
        self.remember_token            = self.class.make_token
        save(false)
      end

      ***REMOVED*** refresh token (keeping same expires_at) if it exists
      def refresh_token
        if remember_token?
          self.remember_token = self.class.make_token 
          save(false)      
        end
      end

      ***REMOVED*** 
      ***REMOVED*** Deletes the server-side record of the authentication token.  The
      ***REMOVED*** client-side (browser cookie) and server-side (this remember_token) must
      ***REMOVED*** always be deleted together.
      ***REMOVED***
      def forget_me
        self.remember_token_expires_at = nil
        self.remember_token            = nil
        save(false)
      end
    end ***REMOVED*** instance methods
  end

  module ByCookieTokenController
    ***REMOVED*** Stuff directives into including module 
    def self.included( recipient )
      recipient.extend( ControllerClassMethods )
      recipient.class_eval do
        include ControllerInstanceMethods
      end
    end

    ***REMOVED***
    ***REMOVED*** Class Methods
    ***REMOVED***
    module ControllerClassMethods
    end ***REMOVED*** class methods
    
    module ControllerInstanceMethods
    end ***REMOVED*** instance methods
  end
end

