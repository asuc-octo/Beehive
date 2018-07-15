# UCB::LDAP initialization
# To supply bind credentials, set LDAP_USERNAME and LDAP_PASSWORD environment vars

require 'ucb_ldap'

begin

  username, password = ENV['LDAP_USERNAME'], ENV['LDAP_PASSWORD']
  if username && password
    UCB::LDAP::authenticate(username, password)
  else
    $stderr.puts "ERROR: LDAP bind credentials have not been set!"
  end

rescue UCB::LDAP::BindFailedException => e
  $stderr.puts "WARNING: Failed to bind: #{e.inspect}"

rescue RuntimeError => e  # UCB::LDAP throws this for missing file
  $stderr.puts "WARNING: Missing file: #{e.inspect}"

end
