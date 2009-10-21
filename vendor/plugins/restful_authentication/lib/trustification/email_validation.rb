module Trustification
  module EmailValidation
    unless Object.constants.include? "CONSTANTS_DEFINED"
      CONSTANTS_DEFINED = true ***REMOVED*** sorry for the C idiom
    end
    
    def self.included(recipient)
      recipient.extend(ClassMethods)
      recipient.class_eval do
        include InstanceMethods
      end
    end

    module ClassMethods
    end ***REMOVED*** class methods

    module InstanceMethods
    end ***REMOVED*** instance methods
  end
end
