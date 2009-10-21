require 'digest/sha1'

class <%= class_name %> < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
<% if options[:aasm] -%>
  include Authorization::AasmRoles
<% elsif options[:stateful] -%>
  include Authorization::StatefulRoles<% end %>
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 ***REMOVED***r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  <% if options[:include_activation] && !options[:stateful] %>before_create :make_activation_code <% end %>

  ***REMOVED*** HACK HACK HACK -- how to do attr_accessible from here?
  ***REMOVED*** prevents a user from submitting a crafted form that bypasses activation
  ***REMOVED*** anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation

<% if options[:include_activation] && !options[:stateful] %>
  ***REMOVED*** Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  ***REMOVED*** Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def active?
    ***REMOVED*** the existence of an activation code means they have not activated yet
    activation_code.nil?
  end<% end %>

  ***REMOVED*** Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  ***REMOVED***
  ***REMOVED*** uff.  this is really an authorization, not authentication routine.  
  ***REMOVED*** We really need a Dispatch Chain here or something.
  ***REMOVED*** This will also let us return a human error message.
  ***REMOVED***
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = <% if    options[:stateful]           %>find_in_state :first, :active, :conditions => {:login => login.downcase}<%
           elsif options[:include_activation] %>find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]<%
           else %>find_by_login(login.downcase)<% end %> ***REMOVED*** need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  protected
    
<% if options[:include_activation] -%>
    def make_activation_code
  <% if options[:stateful] -%>
      self.deleted_at = nil
  <% end -%>
      self.activation_code = self.class.make_token
    end
<% end %>

end
