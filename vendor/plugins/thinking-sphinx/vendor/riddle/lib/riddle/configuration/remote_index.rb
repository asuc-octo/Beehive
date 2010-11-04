module Riddle
  class Configuration
    class RemoteIndex
      attr_accessor :address, :port, :name
      
      def initialize(address, port, name)
        @address  = address
        @port     = port
        @name     = name
      end
      
      def remote
        "***REMOVED***{address}:***REMOVED***{port}"
      end
    end
  end
end