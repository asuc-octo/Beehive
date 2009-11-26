module AutoCompleteMacrosHelper      
  ***REMOVED*** Adds AJAX autocomplete functionality to the text input field with the 
  ***REMOVED*** DOM ID specified by +field_id+.
  ***REMOVED***
  ***REMOVED*** This function expects that the called action returns an HTML <ul> list,
  ***REMOVED*** or nothing if no entries should be displayed for autocompletion.
  ***REMOVED***
  ***REMOVED*** You'll probably want to turn the browser's built-in autocompletion off,
  ***REMOVED*** so be sure to include an <tt>autocomplete="off"</tt> attribute with your text
  ***REMOVED*** input field.
  ***REMOVED***
  ***REMOVED*** The autocompleter object is assigned to a Javascript variable named <tt>field_id</tt>_auto_completer.
  ***REMOVED*** This object is useful if you for example want to trigger the auto-complete suggestions through
  ***REMOVED*** other means than user input (for that specific case, call the <tt>activate</tt> method on that object). 
  ***REMOVED*** 
  ***REMOVED*** Required +options+ are:
  ***REMOVED*** <tt>:url</tt>::                  URL to call for autocompletion results
  ***REMOVED***                                  in url_for format.
  ***REMOVED*** 
  ***REMOVED*** Addtional +options+ are:
  ***REMOVED*** <tt>:update</tt>::               Specifies the DOM ID of the element whose 
  ***REMOVED***                                  innerHTML should be updated with the autocomplete
  ***REMOVED***                                  entries returned by the AJAX request. 
  ***REMOVED***                                  Defaults to <tt>field_id</tt> + '_auto_complete'
  ***REMOVED*** <tt>:with</tt>::                 A JavaScript expression specifying the
  ***REMOVED***                                  parameters for the XMLHttpRequest. This defaults
  ***REMOVED***                                  to 'fieldname=value'.
  ***REMOVED*** <tt>:frequency</tt>::            Determines the time to wait after the last keystroke
  ***REMOVED***                                  for the AJAX request to be initiated.
  ***REMOVED*** <tt>:indicator</tt>::            Specifies the DOM ID of an element which will be
  ***REMOVED***                                  displayed while autocomplete is running.
  ***REMOVED*** <tt>:tokens</tt>::               A string or an array of strings containing
  ***REMOVED***                                  separator tokens for tokenized incremental 
  ***REMOVED***                                  autocompletion. Example: <tt>:tokens => ','</tt> would
  ***REMOVED***                                  allow multiple autocompletion entries, separated
  ***REMOVED***                                  by commas.
  ***REMOVED*** <tt>:min_chars</tt>::            The minimum number of characters that should be
  ***REMOVED***                                  in the input field before an Ajax call is made
  ***REMOVED***                                  to the server.
  ***REMOVED*** <tt>:on_hide</tt>::              A Javascript expression that is called when the
  ***REMOVED***                                  autocompletion div is hidden. The expression
  ***REMOVED***                                  should take two variables: element and update.
  ***REMOVED***                                  Element is a DOM element for the field, update
  ***REMOVED***                                  is a DOM element for the div from which the
  ***REMOVED***                                  innerHTML is replaced.
  ***REMOVED*** <tt>:on_show</tt>::              Like on_hide, only now the expression is called
  ***REMOVED***                                  then the div is shown.
  ***REMOVED*** <tt>:after_update_element</tt>:: A Javascript expression that is called when the
  ***REMOVED***                                  user has selected one of the proposed values. 
  ***REMOVED***                                  The expression should take two variables: element and value.
  ***REMOVED***                                  Element is a DOM element for the field, value
  ***REMOVED***                                  is the value selected by the user.
  ***REMOVED*** <tt>:select</tt>::               Pick the class of the element from which the value for 
  ***REMOVED***                                  insertion should be extracted. If this is not specified,
  ***REMOVED***                                  the entire element is used.
  ***REMOVED*** <tt>:method</tt>::               Specifies the HTTP verb to use when the autocompletion
  ***REMOVED***                                  request is made. Defaults to POST.
  def auto_complete_field(field_id, options = {})
    function =  "var ***REMOVED***{field_id}_auto_completer = new Ajax.Autocompleter("
    function << "'***REMOVED***{field_id}', "
    function << "'" + (options[:update] || "***REMOVED***{field_id}_auto_complete") + "', "
    function << "'***REMOVED***{url_for(options[:url])}' "

    
    js_options = {}
    js_options[:tokens] = array_or_string_for_javascript(options[:tokens]) if options[:tokens]
    js_options[:callback]   = "function(element, value) { return ***REMOVED***{options[:with]} }" if options[:with]
    js_options[:indicator]  = "'***REMOVED***{options[:indicator]}'" if options[:indicator]
    js_options[:select]     = "'***REMOVED***{options[:select]}'" if options[:select]
    js_options[:paramName]  = "'***REMOVED***{options[:param_name]}'" if options[:param_name]
    js_options[:frequency]  = "***REMOVED***{options[:frequency]}" if options[:frequency]
    js_options[:method]     = "'***REMOVED***{options[:method].to_s}'" if options[:method]

    { :after_update_element => :afterUpdateElement, 
      :on_show => :onShow, :on_hide => :onHide, :min_chars => :minChars }.each do |k,v|
      js_options[v] = options[k] if options[k]
    end

    ***REMOVED***function << (', ' + options_for_javascript(js_options) + ')')
	function << ", {tokens: ','})"

    javascript_tag(function)
  end
  
  ***REMOVED*** Use this method in your view to generate a return for the AJAX autocomplete requests.
  ***REMOVED***
  ***REMOVED*** Example action:
  ***REMOVED***
  ***REMOVED***   def auto_complete_for_item_title
  ***REMOVED***     @items = Item.find(:all, 
  ***REMOVED***       :conditions => [ 'LOWER(description) LIKE ?', 
  ***REMOVED***       '%' + request.raw_post.downcase + '%' ])
  ***REMOVED***     render :inline => "<%= auto_complete_result(@items, 'description') %>"
  ***REMOVED***   end
  ***REMOVED***
  ***REMOVED*** The auto_complete_result can of course also be called from a view belonging to the 
  ***REMOVED*** auto_complete action if you need to decorate it further.
  def auto_complete_result(entries, field, phrase = nil)
    return unless entries
    items = entries.map { |entry| content_tag("li", phrase ? highlight(entry[field], phrase) : h(entry[field])) }
    content_tag("ul", items.uniq)
  end
  
  ***REMOVED*** Wrapper for text_field with added AJAX autocompletion functionality.
  ***REMOVED***
  ***REMOVED*** In your controller, you'll need to define an action called
  ***REMOVED*** auto_complete_for to respond the AJAX calls,
  ***REMOVED*** 
  def text_field_with_auto_complete(object, method, tag_options = {}, completion_options = {})
    (completion_options[:skip_style] ? "" : auto_complete_stylesheet) +
    text_field(object, method, tag_options) +
    content_tag("div", "", :id => "***REMOVED***{object}_***REMOVED***{method}_auto_complete", :class => "auto_complete") +
    auto_complete_field("***REMOVED***{object}_***REMOVED***{method}", { :url => { :action => "auto_complete_for_***REMOVED***{object}_***REMOVED***{method}" } }.update(completion_options))
  end

  private
    def auto_complete_stylesheet
      content_tag('style', <<-EOT, :type => Mime::CSS)
        div.auto_complete {
          width: 350px;
          background: ***REMOVED***fff;
        }
        div.auto_complete ul {
          border:1px solid ***REMOVED***888;
          margin:0;
          padding:0;
          width:100%;
          list-style-type:none;
        }
        div.auto_complete ul li {
          margin:0;
          padding:3px;
        }
        div.auto_complete ul li.selected {
          background-color: ***REMOVED***ffb;
        }
        div.auto_complete ul strong.highlight {
          color: ***REMOVED***800; 
          margin:0;
          padding:0;
        }
      EOT
    end

end   
