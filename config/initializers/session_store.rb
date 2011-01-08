***REMOVED*** Be sure to restart your server when you modify this file.

***REMOVED*** Your secret key for verifying cookie session data integrity.
***REMOVED*** If you change this key, all old sessions will become invalid!
***REMOVED*** Make sure the secret is at least 30 characters and all random, 
***REMOVED*** no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_research_session',
***REMOVED***  :secret      => '2b012fa41fee4b212f851c749590d9e3198032513234afb54055c2489eebf3c978af9efefbb1a1e1079a35af76cea455d854729b78969cb8afdc3b1b683eaff1'
  :secret      => ActiveSupport::SecureRandom.hex(127)
}

***REMOVED*** Use the database for sessions instead of the cookie-based default,
***REMOVED*** which shouldn't be used to store highly confidential information
***REMOVED*** (create the session table with "rake db:sessions:create")
***REMOVED*** ActionController::Base.session_store = :active_record_store
