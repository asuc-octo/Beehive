***REMOVED***
***REMOVED*** What you should see when you get there
***REMOVED***

***REMOVED***
***REMOVED*** Destinations.  Ex:
***REMOVED***   She should be at the new kids page
***REMOVED***   Tarkin should be at the destroy alderaan page
***REMOVED***   The visitor should be at the '/lolcats/download' form
***REMOVED***   The visitor should be redirected to '/hi/mom'
***REMOVED***
***REMOVED*** It doesn't know anything about actual routes -- it just
***REMOVED*** feeds its output to render_template or redirect_to
***REMOVED***
Then "$actor should be at $path" do |_, path|
  response.should render_template(grok_path(path))
end

Then "$actor should be redirected to $path" do |_, path|
  response.should redirect_to(grok_path(path))
end

Then "the page should look AWESOME" do
  response.should have_tag('head>title')
  response.should have_tag('h1')
  ***REMOVED*** response.should be_valid_xhtml
end

***REMOVED***
***REMOVED*** Tags
***REMOVED***

Then "the page should contain '$text'" do |_, text|
  response.should have_text(/***REMOVED***{text}/)
end

***REMOVED*** please note: this enforces the use of a <label> field
Then "$actor should see a <$container> containing a $attributes" do |_, container, attributes|
  attributes = attributes.to_hash_from_story
  response.should have_tag(container) do
    attributes.each do |tag, label|
      case tag
      when "textfield" then with_tag "input[type='text']";     with_tag("label", label)
      when "password"  then with_tag "input[type='password']"; with_tag("label", label)
      when "submit"    then with_tag "input[type='submit'][value='***REMOVED***{label}']"
      else with_tag tag, label
      end
    end
  end
end

***REMOVED***
***REMOVED*** Session, cookie variables
***REMOVED***
Then "$actor $token cookie should include $attrlist" do |_, token, attrlist|
  attrlist = attrlist.to_array_from_story
  cookies.include?(token).should be_true
  attrlist.each do |val|
    cookies[token].include?(val).should be_true
  end
end

Then "$actor $token cookie should exist but not include $attrlist" do |_, token, attrlist|
  attrlist = attrlist.to_array_from_story
  cookies.include?(token).should be_true
  puts [cookies, attrlist, token].to_yaml
  attrlist.each do |val|
    cookies[token].include?(val).should_not be_true
  end
end

Then "$actor should have $an $token cookie" do |_, _, token|
  cookies[token].should_not be_blank
end
Then "$actor should not have $an $token cookie" do |_, _, token|
  cookies[token].should be_blank
end

Given "$actor has $an cookie jar with $attributes" do |_, _, attributes|
  attributes = attributes.to_hash_from_story
  attributes.each do |attr, val|
    cookies[attr] = val
  end
end
Given "$actor session store has no $attrlist" do |_, attrlist|
  attrlist = attrlist.to_array_from_story
  attrlist.each do |attr|
    ***REMOVED*** Note that the comparison passes through 'to_s'
    session[attr.to_sym] = nil
  end
end

Then "$actor session store should have $attributes" do |_, attributes|
  attributes = attributes.to_hash_from_story
  attributes.each do |attr, val|
    ***REMOVED*** Note that the comparison passes through 'to_s'
    session[attr.to_sym].to_s.should eql(val)
  end
end

Then "$actor session store should not have $attrlist" do |_, attrlist|
  attrlist = attrlist.to_array_from_story
  attrlist.each do |attr|
    session[attr.to_sym].blank?.should be_true
  end
end

***REMOVED***
***REMOVED*** Flash messages
***REMOVED***

Then /^she should +see an? (\w+) message '([\w !\']+)'$/ do |notice, message|
  response.should have_flash(notice, %r{***REMOVED***{message}})
end

Then "$actor should not see $an $notice message '$message'" do |_, _, notice, message|
  response.should_not have_flash(notice, %r{***REMOVED***{message}})
end

Then "$actor should see no messages" do |_|
  ['error', 'warning', 'notice'].each do |notice|
    response.should_not have_flash(notice)
  end
end

RE_POLITENESS = /(?:please|sorry|thank(?:s| you))/i
Then %r{we should be polite about it} do
  response.should have_tag("div.error,div.notice", RE_POLITENESS)
end
Then %r{we should not even be polite about it} do
  response.should_not have_tag("div.error,div.notice", RE_POLITENESS)
end

***REMOVED***
***REMOVED*** Resource's attributes
***REMOVED***
***REMOVED*** "Then page should have the $resource's $attributes" is in resource_steps

***REMOVED*** helpful debug step
Then "we dump the response" do
  dump_response
end


def have_flash notice, *args
  have_tag("div.***REMOVED***{notice}", *args)
end

RE_PRETTY_RESOURCE = /the (index|show|new|create|edit|update|destroy) (\w+) (page|form)/i
RE_THE_FOO_PAGE    = /the '?([^']*)'? (page|form)/i
RE_QUOTED_PATH     = /^'([^']*)'$/i
def grok_path path
  path.gsub(/\s+again$/,'') ***REMOVED*** strip trailing ' again'
  case
  when path == 'the home page'    then dest = '/'
  when path =~ RE_PRETTY_RESOURCE then dest = template_for $1, $2
  when path =~ RE_THE_FOO_PAGE    then dest = $1
  when path =~ RE_QUOTED_PATH     then dest = $1
  else                                 dest = path
  end
  dest
end

***REMOVED*** turns 'new', 'road bikes' into 'road_bikes/new'
***REMOVED*** note that it's "action resource"
def template_for(action, resource)
  "***REMOVED***{resource.gsub(" ","_")}/***REMOVED***{action}"
end

