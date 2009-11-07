***REMOVED***
***REMOVED*** Where to go
***REMOVED***

***REMOVED***
***REMOVED*** GET
***REMOVED*** Go to a given page.
When "$actor goes to $path" do |actor, path|
  case path
  when 'the home page' then get '/'
  else                      get path
  end
end

***REMOVED*** POST -- Ex:
***REMOVED***   When she creates a book with ISBN: '0967539854' and comment: 'I love this book' and rating: '4'
***REMOVED***   When she creates a singular session with login: 'reggie' and password: 'i_haxxor_joo'
***REMOVED*** Since I'm not smart enough to do it right, explicitly specify singular resources
When /^(\w+) creates an? ([\w ]+) with ([\w: \',]+)$/ do |actor, resource, attributes|
  attributes = attributes.to_hash_from_story
  if resource =~ %r{singular ([\w/]+)}
    resource = $1.downcase.singularize
    post "/***REMOVED***{resource}", attributes
  else
    post "/***REMOVED***{resource.downcase.pluralize}", { resource.downcase.singularize => attributes }
  end
end

***REMOVED*** PUT
When %r{$actor asks to update '$resource' with $attributes} do |_, resource, attributes|
  attributes = attributes.to_hash_from_story
  put "***REMOVED***{resource}", attributes
  dump_response
end

***REMOVED*** DELETE -- Slap together the POST-form-as-fake-HTTP-DELETE submission
When %r{$actor asks to delete '$resource'} do |_, resource|
  post "/***REMOVED***{resource.downcase.pluralize}", { :_method => :delete }
  dump_response
end


***REMOVED*** Redirect --
***REMOVED***   Rather than coding in get/get_via_redirect's and past/p_v_r's,
***REMOVED***   let's just demand that in the story itself.
When "$actor follows that redirect!" do |actor|
  follow_redirect!
end
