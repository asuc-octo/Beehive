module ThinkingSphinx
  module ActiveRecord
    ***REMOVED*** This module contains all the delta-related code for models. There isn't
    ***REMOVED*** really anything you need to call manually in here - except perhaps
    ***REMOVED*** index_delta, but not sure what reason why.
    ***REMOVED*** 
    module Delta
      ***REMOVED*** Code for after_commit callback is written by Eli Miller:
      ***REMOVED*** http://elimiller.blogspot.com/2007/06/proper-cache-expiry-with-aftercommit.html
      ***REMOVED*** with slight modification from Joost Hietbrink.
      ***REMOVED***
      def self.included(base)
        base.class_eval do
          class << self
            ***REMOVED*** Build the delta index for the related model. This won't be called
            ***REMOVED*** if running in the test environment.
            ***REMOVED***
            def index_delta(instance = nil)
              delta_object.index(self, instance)
            end
            
            def delta_object
              self.sphinx_indexes.first.delta_object
            end
          end
          
          def toggled_delta?
            self.class.delta_object.toggled(self)
          end
          
          private
          
          ***REMOVED*** Set the delta value for the model to be true.
          def toggle_delta
            self.class.delta_object.toggle(self) if should_toggle_delta?
          end
          
          ***REMOVED*** Build the delta index for the related model. This won't be called
          ***REMOVED*** if running in the test environment.
          ***REMOVED*** 
          def index_delta
            self.class.index_delta(self) if self.class.delta_object.toggled(self)
          end
          
          def should_toggle_delta?
            self.new_record? || indexed_data_changed?
          end
          
          def indexed_data_changed?
            sphinx_indexes.any? { |index|
              index.fields.any? { |field| field.changed?(self) } ||
              index.attributes.any? { |attrib|
                attrib.public? && attrib.changed?(self) && !attrib.updatable?
              }
            }
          end
        end
      end
    end
  end
end
