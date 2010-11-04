module ThinkingSphinx
  class Index
    ***REMOVED*** Instances of this class represent database columns and the stack of
    ***REMOVED*** associations that lead from the base model to them.
    ***REMOVED*** 
    ***REMOVED*** The name and stack are accessible through methods starting with __ to
    ***REMOVED*** avoid conflicting with the method_missing calls that build the stack.
    ***REMOVED*** 
    class FauxColumn
      ***REMOVED*** Create a new column with a pre-defined stack. The top element in the
      ***REMOVED*** stack will get shifted to be the name value.
      ***REMOVED*** 
      def initialize(*stack)
        @name  = stack.pop
        @stack = stack
      end
      
      def self.coerce(columns)
        case columns
        when Symbol, String
          FauxColumn.new(columns)
        when Array
          columns.collect { |col| FauxColumn.coerce(col) }
        when FauxColumn
          columns
        else
          nil
        end
      end
      
      ***REMOVED*** Can't use normal method name, as that could be an association or
      ***REMOVED*** column name.
      ***REMOVED*** 
      def __name
        @name
      end
      
      ***REMOVED*** Can't use normal method name, as that could be an association or
      ***REMOVED*** column name.
      ***REMOVED*** 
      def __stack
        @stack
      end
      
      def __path
        @stack + [@name]
      end
      
      ***REMOVED*** Returns true if the stack is empty *and* if the name is a string -
      ***REMOVED*** which is an indication that of raw SQL, as opposed to a value from a
      ***REMOVED*** table's column.
      ***REMOVED*** 
      def is_string?
        @name.is_a?(String) && @stack.empty?
      end
      
      def to_ary
        [self]
      end
      
      ***REMOVED*** This handles any 'invalid' method calls and sets them as the name,
      ***REMOVED*** and pushing the previous name into the stack. The object returns
      ***REMOVED*** itself.
      ***REMOVED*** 
      ***REMOVED*** If there's a single argument, it becomes the name, and the method
      ***REMOVED*** symbol goes into the stack as well. Multiple arguments means new
      ***REMOVED*** columns with the original stack and new names (from each argument) gets
      ***REMOVED*** returned.
      ***REMOVED*** 
      ***REMOVED*** Easier to explain with examples:
      ***REMOVED*** 
      ***REMOVED***   col = FauxColumn.new :a, :b, :c
      ***REMOVED***   col.__name  ***REMOVED***=> :c
      ***REMOVED***   col.__stack ***REMOVED***=> [:a, :b]
      ***REMOVED*** 
      ***REMOVED***   col.whatever ***REMOVED***=> col
      ***REMOVED***   col.__name  ***REMOVED***=> :whatever
      ***REMOVED***   col.__stack ***REMOVED***=> [:a, :b, :c]
      ***REMOVED***
      ***REMOVED***   col.something(:id) ***REMOVED***=> col
      ***REMOVED***   col.__name  ***REMOVED***=> :id
      ***REMOVED***   col.__stack ***REMOVED***=> [:a, :b, :c, :whatever, :something]
      ***REMOVED***
      ***REMOVED***   cols = col.short(:x, :y, :z)
      ***REMOVED***   cols[0].__name  ***REMOVED***=> :x
      ***REMOVED***   cols[0].__stack ***REMOVED***=> [:a, :b, :c, :whatever, :something, :short]
      ***REMOVED***   cols[1].__name  ***REMOVED***=> :y
      ***REMOVED***   cols[1].__stack ***REMOVED***=> [:a, :b, :c, :whatever, :something, :short]
      ***REMOVED***   cols[2].__name  ***REMOVED***=> :z
      ***REMOVED***   cols[2].__stack ***REMOVED***=> [:a, :b, :c, :whatever, :something, :short]
      ***REMOVED***   
      ***REMOVED*** Also, this allows method chaining to build up a relevant stack:
      ***REMOVED*** 
      ***REMOVED***   col = FauxColumn.new :a, :b
      ***REMOVED***   col.__name  ***REMOVED***=> :b
      ***REMOVED***   col.__stack ***REMOVED***=> [:a]
      ***REMOVED*** 
      ***REMOVED***   col.one.two.three ***REMOVED***=> col
      ***REMOVED***   col.__name  ***REMOVED***=> :three
      ***REMOVED***   col.__stack ***REMOVED***=> [:a, :b, :one, :two]
      ***REMOVED***
      def method_missing(method, *args)
        @stack << @name
        @name   = method
        
        if (args.empty?)
          self
        elsif (args.length == 1)
          method_missing(args.first)
        else
          args.collect { |arg|
            FauxColumn.new(@stack + [@name, arg])
          }
        end
      end
    end
  end
end