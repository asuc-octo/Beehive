***REMOVED***
***REMOVED*** UCB::LDAP initialization
***REMOVED***
***REMOVED*** Two options for supplying bind credentials:
***REMOVED***   1) set LDAP_USERNAME and LDAP_PASSWORD environment vars
***REMOVED***   2) use config/ldap.yml (generate one with rake ldap:setup)
***REMOVED***

require 'ucb_ldap'

begin
  ***REMOVED*** This has to go in the initializer (not environments/*) because
  ***REMOVED*** we need the ucb_ldap plugin to be loaded, which happens after
  ***REMOVED*** environments are loaded.
  UCB::LDAP.host = case Rails.env
    when 'production'
      UCB::LDAP::HOST_PRODUCTION
    ***REMOVED*** else
    ***REMOVED***   UCB::LDAP::HOST_TEST
  end

  unless Rails.env == 'test'
    ***REMOVED*** 1) Try using env vars
    username, password = ENV['LDAP_USERNAME'], ENV['LDAP_PASSWORD']
    if username && password
      UCB::LDAP::authenticate(username, password)
    ***REMOVED*** 2) Use config/ldap.yml
    else
      UCB::LDAP.bind_for_rails

    end
  end

rescue UCB::LDAP::BindFailedException => e
  $stderr.puts "WARNING: Failed to bind: ***REMOVED***{e.inspect}"

rescue RuntimeError => e  ***REMOVED*** UCB::LDAP throws this for missing file
  $stderr.puts "WARNING: Missing file: ***REMOVED***{e.inspect}"

end
