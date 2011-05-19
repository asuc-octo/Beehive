***REMOVED*** Be sure to restart your server when you modify this file.

***REMOVED***ResearchMatch::Application.config.session_store :cookie_store, :key => '_ResearchMatch_session'

***REMOVED*** Use the database for sessions instead of the cookie-based default,
***REMOVED*** which shouldn't be used to store highly confidential information
***REMOVED*** (create the session table with "rails generate session_migration")
ResearchMatch::Application.config.session_store :active_record_store
