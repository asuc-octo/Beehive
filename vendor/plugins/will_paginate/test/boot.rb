plugin_root = File.join(File.dirname(__FILE__), '..')
version = ENV['RAILS_VERSION']
version = nil if version and version == ""

***REMOVED*** first look for a symlink to a copy of the framework
if !version and framework_root = ["***REMOVED***{plugin_root}/rails", "***REMOVED***{plugin_root}/../../rails"].find { |p| File.directory? p }
  puts "found framework root: ***REMOVED***{framework_root}"
  ***REMOVED*** this allows for a plugin to be tested outside of an app and without Rails gems
  $:.unshift "***REMOVED***{framework_root}/activesupport/lib", "***REMOVED***{framework_root}/activerecord/lib", "***REMOVED***{framework_root}/actionpack/lib"
else
  ***REMOVED*** simply use installed gems if available
  puts "using Rails***REMOVED***{version ? ' ' + version : nil} gems"
  require 'rubygems'
  
  if version
    gem 'rails', version
  else
    gem 'actionpack'
    gem 'activerecord'
  end
end
