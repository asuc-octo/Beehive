module Authorization
  def self.included(recipient)
    recipient.extend(ModelClassMethods)
    recipient.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end ***REMOVED*** class methods

  module ModelInstanceMethods
  end ***REMOVED*** instance methods
end
