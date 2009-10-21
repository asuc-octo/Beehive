Rails::Generator::Commands::Create.class_eval do
  def route_resource(*resources)
    resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
    sentinel = 'ActionController::Routing::Routes.draw do |map|'

    logger.route "map.resource ***REMOVED***{resource_list}"
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(***REMOVED***{Regexp.escape(sentinel)})/mi do |match|
        "***REMOVED***{match}\n  map.resource ***REMOVED***{resource_list}\n"
      end
    end
  end
  
  def route_name(name, path, route_options = {})
    sentinel = 'ActionController::Routing::Routes.draw do |map|'
    
    logger.route "map.***REMOVED***{name} '***REMOVED***{path}', :controller => '***REMOVED***{route_options[:controller]}', :action => '***REMOVED***{route_options[:action]}'"
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(***REMOVED***{Regexp.escape(sentinel)})/mi do |match|
        "***REMOVED***{match}\n  map.***REMOVED***{name} '***REMOVED***{path}', :controller => '***REMOVED***{route_options[:controller]}', :action => '***REMOVED***{route_options[:action]}'"
      end
    end
  end
end

Rails::Generator::Commands::Destroy.class_eval do
  def route_resource(*resources)
    resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
    look_for = "\n  map.resource ***REMOVED***{resource_list}\n"
    logger.route "map.resource ***REMOVED***{resource_list}"
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(***REMOVED***{look_for})/mi, ''
    end
  end
  
  def route_name(name, path, route_options = {})
    look_for =   "\n  map.***REMOVED***{name} '***REMOVED***{path}', :controller => '***REMOVED***{route_options[:controller]}', :action => '***REMOVED***{route_options[:action]}'"
    logger.route "map.***REMOVED***{name} '***REMOVED***{path}',     :controller => '***REMOVED***{route_options[:controller]}', :action => '***REMOVED***{route_options[:action]}'"
    unless options[:pretend]
      gsub_file    'config/routes.rb', /(***REMOVED***{look_for})/mi, ''
    end
  end
end

Rails::Generator::Commands::List.class_eval do
  def route_resource(*resources)
    resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
    logger.route "map.resource ***REMOVED***{resource_list}"
  end
  
  def route_name(name, path, options = {})
    logger.route "map.***REMOVED***{name} '***REMOVED***{path}', :controller => '{options[:controller]}', :action => '***REMOVED***{options[:action]}'"
  end
end
