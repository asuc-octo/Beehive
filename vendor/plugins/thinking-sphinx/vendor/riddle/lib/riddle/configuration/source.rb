module Riddle
  class Configuration
    class Source < Riddle::Configuration::Section
      attr_accessor :name, :parent, :type
            
      def render
        raise ConfigurationError unless valid?
        
        inherited_name = "***REMOVED***{name}"
        inherited_name << " : ***REMOVED***{parent}" if parent
        (
          ["source ***REMOVED***{inherited_name}", "{"] +
          settings_body +
          ["}", ""]
        ).join("\n")
      end
      
      def valid?
        !( @name.nil? || @type.nil? )
      end
    end
  end
end