module AutoComplete      
  
  def self.included(base)
    base.extend(ClassMethods)
  end

  ***REMOVED***
  ***REMOVED*** Example:
  ***REMOVED***
  ***REMOVED***   ***REMOVED*** Controller
  ***REMOVED***   class BlogController < ApplicationController
  ***REMOVED***     auto_complete_for :post, :title
  ***REMOVED***   end
  ***REMOVED***
  ***REMOVED***   ***REMOVED*** View
  ***REMOVED***   <%= text_field_with_auto_complete :post, title %>
  ***REMOVED***
  ***REMOVED*** By default, auto_complete_for limits the results to 10 entries,
  ***REMOVED*** and sorts by the given field.
  ***REMOVED*** 
  ***REMOVED*** auto_complete_for takes a third parameter, an options hash to
  ***REMOVED*** the find method used to search for the records:
  ***REMOVED***
  ***REMOVED***   auto_complete_for :post, :title, :limit => 15, :order => 'created_at DESC'
  ***REMOVED***
  ***REMOVED*** For help on defining text input fields with autocompletion, 
  ***REMOVED*** see ActionView::Helpers::JavaScriptHelper.
  ***REMOVED***
  ***REMOVED*** For more examples, see script.aculo.us:
  ***REMOVED*** * http://script.aculo.us/demos/ajax/autocompleter
  ***REMOVED*** * http://script.aculo.us/demos/ajax/autocompleter_customized
  module ClassMethods
    def auto_complete_for(object, method, options = {})
      define_method("auto_complete_for_***REMOVED***{object}_***REMOVED***{method}") do
        find_options = { 
          :conditions => [ "LOWER(***REMOVED***{method}) LIKE ?", '%' + params[object][method].downcase + '%' ], 
          :order => "***REMOVED***{method} ASC",
          :limit => 10 }.merge!(options)
        
        @items = object.to_s.camelize.constantize.find(:all, find_options)

        render :inline => "<%= auto_complete_result @items, '***REMOVED***{method}' %>"
      end
    end
  end
  
end