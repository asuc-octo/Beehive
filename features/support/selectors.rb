module HtmlSelectorsHelpers
  ***REMOVED*** Maps a name to a selector. Used primarily by the
  ***REMOVED***
  ***REMOVED***   When /^(.+) within (.+)$/ do |step, scope|
  ***REMOVED***
  ***REMOVED*** step definitions in web_steps.rb
  ***REMOVED***
  def selector_for(locator)
    case locator

    when "the page"
      "html > body"

    ***REMOVED*** Add more mappings here.
    ***REMOVED*** Here is an example that pulls values out of the Regexp:
    ***REMOVED***
    ***REMOVED***  when /^the (notice|error|info) flash$/
    ***REMOVED***    ".flash.***REMOVED***{$1}"

    ***REMOVED*** You can also return an array to use a different selector
    ***REMOVED*** type, like:
    ***REMOVED***
    ***REMOVED***  when /the header/
    ***REMOVED***    [:xpath, "//header"]

    ***REMOVED*** This allows you to provide a quoted selector as the scope
    ***REMOVED*** for "within" steps as was previously the default for the
    ***REMOVED*** web steps:
    when /^"(.+)"$/
      $1

    else
      raise "Can't find mapping from \"***REMOVED***{locator}\" to a selector.\n" +
        "Now, go and add a mapping in ***REMOVED***{__FILE__}"
    end
  end
end

World(HtmlSelectorsHelpers)
