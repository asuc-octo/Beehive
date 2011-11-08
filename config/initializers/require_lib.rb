***REMOVED*** Requires all .rb files in root/lib
***REMOVED*** This is needed because, by default, Rails doesn't load
***REMOVED*** lib files that don't contain matching classes.
***REMOVED*** http://stackoverflow.com/questions/4074830/adding-lib-to-config-autoload-paths-in-rails-3-does-not-autoload-my-module

Dir.glob(File.join(Rails.root, 'lib', '*.rb')).each do |rb|
  require rb
end
