***REMOVED*** The flexible code for resource testing came out of code from Ben Mabey
***REMOVED*** http://www.benmabey.com/2008/02/04/rspec-plain-text-stories-webrat-chunky-bacon/

***REMOVED***
***REMOVED*** Construct resources
***REMOVED***

***REMOVED***
***REMOVED*** Build a resource as described, store it as an @instance variable. Ex:
***REMOVED***   "Given a user with login: 'mojojojo'"
***REMOVED*** produces a User instance stored in @user with 'mojojojo' as its login
***REMOVED*** attribute.
***REMOVED***
Given "a $resource instance with $attributes" do |resource, attributes|
  klass, instance, attributes = parse_resource_args resource, attributes
  instance = klass.new(attributes)
  instance.save!
  find_resource(resource, attributes).should_not be_nil
  keep_instance! resource, instance
end

***REMOVED***
***REMOVED*** Stuff attributes into a preexisting @resource
***REMOVED***   "And the user has thac0: 3"
***REMOVED*** takes the earlier-defined @user instance and sets its thac0 to '3'.
***REMOVED***
Given "the $resource has $attributes" do |resource, attributes|
  klass, instance, attributes = parse_resource_args resource, attributes
  attributes.each do |attr, val|
    instance.send("***REMOVED***{attr}=", val)
  end
  instance.save!
  find_resource(resource, attributes).should_not be_nil
  keep_instance! resource, instance
end

***REMOVED***
***REMOVED*** Destroy all for this resource
***REMOVED***
Given "no $resource with $attr: '$val' exists" do |resource, attr, val|
  klass, instance = parse_resource_args resource
  klass.destroy_all(attr.to_sym => val)
  instance = find_resource resource, attr.to_sym => val
  instance.should be_nil
  keep_instance! resource, instance
end

***REMOVED***
***REMOVED*** Then's for resources
***REMOVED***

***REMOVED*** Resource like this DOES exist
Then /^a (\w+) with ([\w: \']+) should exist$/ do |resource, attributes|
  instance = find_resource resource, attributes
  instance.should_not be_nil
  keep_instance! resource, instance
end
***REMOVED*** Resource like this DOES NOT exist
Then /^no (\w+) with ([\w: \']+) should exist$/ do |resource, attributes|
  instance = find_resource resource, attributes
  instance.should be_nil
end

***REMOVED*** Resource has attributes with given values
Then  "the $resource should have $attributes" do |resource, attributes|
  klass, instance, attributes = parse_resource_args resource, attributes
  attributes.each do |attr, val|
    instance.send(attr).should == val
  end
end

***REMOVED*** Resource attributes should / should not be nil
Then  "the $resource's $attr should be nil" do |resource, attr|
  klass, instance = parse_resource_args resource
  instance.send(attr).should be_nil
end
Then  "the $resource's $attr should not be nil" do |resource, attr|
  klass, instance = parse_resource_args resource
  instance.send(attr).should_not be_nil
end

***REMOVED***
***REMOVED*** Bank each of the @resource's listed attributes for later.
***REMOVED***
Given "we try hard to remember the $resource's $attributes" do |resource, attributes|
  attributes = attributes.to_array_from_story
  attributes.each do |attr|
    memorize_resource_value resource, attr
  end
end
***REMOVED***
***REMOVED*** Bank each of the @resource's listed attributes for later.
***REMOVED***
Given "we don't remember anything about the past" do
  memorize_forget_all!
end

***REMOVED***
***REMOVED*** Compare @resource.attr to its earlier-memorized value.
***REMOVED*** Specify ' using method_name' (abs, to_s, &c) to coerce before comparing.
***REMOVED*** For important and mysterious reasons, timestamps want to_i or to_s.
***REMOVED***
Then /^the (\w+)\'s (\w+) should stay the same under (\w+)$/ do |resource, attr, func|
  klass, instance = parse_resource_args resource
  ***REMOVED*** Get the values
  old_value = recall_resource_value(resource, attr)
  new_value = instance.send(attr)
  ***REMOVED*** Transform each value, maybe, using value.func
  if func then new_value = new_value.send(func); old_value = old_value.send(func) end
  ***REMOVED*** Compare
  old_value.should eql(new_value)
end

***REMOVED***
***REMOVED*** Look for each for the given attributes in the page's text
***REMOVED***
Then "page should have the $resource's $attributes" do |resource, attributes|
  actual_resource = instantize(resource)
  attributes.split(/, and |, /).each do |attribute|
    response.should have_text(/***REMOVED***{actual_resource.send(attribute.strip.gsub(" ","_"))}/)
  end
end

***REMOVED***
***REMOVED*** Turn a resource name and a to_hash_from_story string like
***REMOVED***   "attr: 'value', attr2: 'value2', ... , and attrN: 'valueN'"
***REMOVED*** into
***REMOVED***   * klass      -- the class matching that Resource
***REMOVED***   * instance   -- the possibly-preexisting local instance value @resource
***REMOVED***   * attributes -- a hash matching the given attribute-list string
***REMOVED***
def parse_resource_args resource, attributes=nil
  instance   = instantize resource
  klass      = resource.classify.constantize
  attributes = attributes.to_hash_from_story if attributes
  [klass, instance, attributes]
end

***REMOVED***
***REMOVED*** Given a class name 'resource' and a hash of conditsion, find a model
***REMOVED***
def find_resource resource, conditions
  klass, instance = parse_resource_args resource
  conditions = conditions.to_hash_from_story unless (conditions.is_a? Hash)
  klass.find(:first, :conditions => conditions)
end

***REMOVED***
***REMOVED*** Simple, brittle, useful: store the given resource's attribute
***REMOVED*** so we can compare it later.
***REMOVED***
def memorize_resource_value resource, attr
  klass, instance = parse_resource_args resource
  value = instance.send(attr)
  @_memorized ||= {}
  @_memorized[resource] ||= {}
  @_memorized[resource][attr] = value
  value
end
def recall_resource_value resource, attr
  @_memorized[resource][attr]
end
def memorize_forget_all!
  @_memorized = {}
end

***REMOVED***
***REMOVED*** Keep the object around in a local instance variable @resource.
***REMOVED***
***REMOVED*** So, for instance,
***REMOVED***   klass, instance = parse_resource_args 'user'
***REMOVED***   instance = klass.new({login => 'me', password => 'monkey', ...})
***REMOVED***   keep_instance! resource, instance
***REMOVED*** keeps the just-constructed User model in the @user instance variable.
***REMOVED***
def keep_instance! resource, object
  instance_variable_set("@***REMOVED***{resource}", object)
end
