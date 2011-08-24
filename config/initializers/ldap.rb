require 'ucb_ldap'

begin
  ***REMOVED*** This has to go in the initializer (not environments/*) because
  ***REMOVED*** we need the ucb_ldap plugin to be loaded, which happens after
  ***REMOVED*** environments are loaded.
  UCB::LDAP.host = case Rails.env
    when 'production'
      UCB::LDAP::HOST_PRODUCTION
    else
      UCB::LDAP::HOST_TEST
  end

  UCB::LDAP.bind_for_rails unless Rails.env == 'test'
rescue UCB::LDAP::BindFailedException => e
  $stderr.puts "ERROR: Failed to bind: ***REMOVED***{e.inspect}"
end
