***REMOVED*** These settings change the behavior of Rails 2 apps and will be defaults
***REMOVED*** for Rails 3. You can remove this initializer when Rails 3 is released.

if defined?(ActiveRecord)
  ***REMOVED*** Include Active Record class name as root for JSON serialized output.
  ActiveRecord::Base.include_root_in_json = true

  ***REMOVED*** Store the full class name (including module namespace) in STI type column.
  ActiveRecord::Base.store_full_sti_class = true
end

***REMOVED*** Use ISO 8601 format for JSON serialized times and dates.
ActiveSupport.use_standard_json_time_format = true

***REMOVED*** Don't escape HTML entities in JSON, leave that for the ***REMOVED***json_escape helper.
***REMOVED*** if you're including raw json in an HTML page.
ActiveSupport.escape_html_entities_in_json = false