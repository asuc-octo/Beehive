module Authentication
  module ByPassword
    ***REMOVED*** Stuff directives into including module
    def self.included(recipient)
      recipient.extend(ModelClassMethods)
      recipient.class_eval do
        include ModelInstanceMethods
        
        ***REMOVED*** Virtual attribute for the unencrypted password
        attr_accessor :password
        validates_presence_of     :password,                   :if => :password_required?
        validates_presence_of     :password_confirmation,      :if => :password_required?
        validates_confirmation_of :password,                   :if => :password_required?
        validates_length_of       :password, :within => 6..40, :if => :password_required?
        before_save :encrypt_password
      end
    end ***REMOVED*** ***REMOVED***included directives

    ***REMOVED***
    ***REMOVED*** Class Methods
    ***REMOVED***
    module ModelClassMethods
      ***REMOVED*** This provides a modest increased defense against a dictionary attack if
      ***REMOVED*** your db were ever compromised, but will invalidate existing passwords.
      ***REMOVED*** See the README and the file config/initializers/site_keys.rb
      ***REMOVED***
      ***REMOVED*** It may not be obvious, but if you set REST_AUTH_SITE_KEY to nil and
      ***REMOVED*** REST_AUTH_DIGEST_STRETCHES to 1 you'll have backwards compatibility with
      ***REMOVED*** older versions of restful-authentication.
      def password_digest(password, salt)
        digest = REST_AUTH_SITE_KEY
        REST_AUTH_DIGEST_STRETCHES.times do
          digest = secure_digest(digest, salt, password, REST_AUTH_SITE_KEY)
        end
        digest
      end      
    end ***REMOVED*** class methods

    ***REMOVED***
    ***REMOVED*** Instance Methods
    ***REMOVED***
    module ModelInstanceMethods
      
      ***REMOVED*** Encrypts the password with the user salt
      def encrypt(password)
        self.class.password_digest(password, salt)
      end
      
      def authenticated?(password)
        crypted_password == encrypt(password)
      end
      
      ***REMOVED*** before filter 
      def encrypt_password
        return if password.blank?
        self.salt = self.class.make_token if new_record?
        self.crypted_password = encrypt(password)
      end
      def password_required?
        crypted_password.blank? || !password.blank?
      end
    end ***REMOVED*** instance methods
  end
end
