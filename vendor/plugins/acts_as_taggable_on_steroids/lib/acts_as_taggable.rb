module ActiveRecord ***REMOVED***:nodoc:
  module Acts ***REMOVED***:nodoc:
    module Taggable ***REMOVED***:nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_taggable
          raise "acts_as_taggable_on_steroids has been moved to github: http://github.com/jviney/acts_as_taggable_on_steroids"
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Taggable)
