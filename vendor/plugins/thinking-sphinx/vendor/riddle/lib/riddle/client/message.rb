module Riddle
  class Client
    ***REMOVED*** This class takes care of the translation of ints, strings and arrays to
    ***REMOVED*** the format required by the Sphinx service.
    class Message
      def initialize
        @message = ""
        @size_method = @message.respond_to?(:bytesize) ? :bytesize : :length
      end
      
      ***REMOVED*** Append raw data (only use if you know what you're doing)
      def append(*args)
        args.each { |arg| @message << arg }
      end
      
      ***REMOVED*** Append a string's length, then the string itself
      def append_string(str)
        string = str.respond_to?(:force_encoding) ?
          str.dup.force_encoding('ASCII-8BIT') : str
        
        @message << [string.send(@size_method)].pack('N') + string
      end
      
      ***REMOVED*** Append an integer
      def append_int(int)
        @message << [int.to_i].pack('N')
      end
      
      def append_64bit_int(int)
        @message << [int.to_i >> 32, int.to_i & 0xFFFFFFFF].pack('NN')
      end
      
      ***REMOVED*** Append a float
      def append_float(float)
        @message << [float].pack('f').unpack('L*').pack("N")
      end
      
      def append_boolean(bool)
        append_int(bool ? 1 : 0)
      end
      
      ***REMOVED*** Append multiple integers
      def append_ints(*ints)
        ints.each { |int| append_int(int) }
      end
      
      def append_64bit_ints(*ints)
        ints.each { |int| append_64bit_int(int) }
      end
      
      ***REMOVED*** Append multiple floats
      def append_floats(*floats)
        floats.each { |float| append_float(float) }
      end
      
      ***REMOVED*** Append an array of strings - first appends the length of the array,
      ***REMOVED*** then each item's length and value.
      def append_array(array)
        append_int(array.length)
        
        array.each { |item| append_string(item) }
      end
      
      ***REMOVED*** Returns the entire message
      def to_s
        @message
      end
    end
  end
end
