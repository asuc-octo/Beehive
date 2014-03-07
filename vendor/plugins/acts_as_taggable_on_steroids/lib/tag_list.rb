class TagList < Array
  cattr_accessor :delimiter
  self.delimiter = ','
  
  def initialize(*args)
    add(*args)
  end
  
  ***REMOVED*** Add tags to the tag_list. Duplicate or blank tags will be ignored.
  ***REMOVED***
  ***REMOVED***   tag_list.add("Fun", "Happy")
  ***REMOVED*** 
  ***REMOVED*** Use the <tt>:parse</tt> option to add an unparsed tag string.
  ***REMOVED***
  ***REMOVED***   tag_list.add("Fun, Happy", :parse => true)
  def add(*names)
    extract_and_apply_options!(names)
    concat(names)
    clean!
    self
  end
  
  ***REMOVED*** Remove specific tags from the tag_list.
  ***REMOVED*** 
  ***REMOVED***   tag_list.remove("Sad", "Lonely")
  ***REMOVED***
  ***REMOVED*** Like ***REMOVED***add, the <tt>:parse</tt> option can be used to remove multiple tags in a string.
  ***REMOVED*** 
  ***REMOVED***   tag_list.remove("Sad, Lonely", :parse => true)
  def remove(*names)
    extract_and_apply_options!(names)
    delete_if { |name| names.include?(name) }
    self
  end
  
  ***REMOVED*** Toggle the presence of the given tags.
  ***REMOVED*** If a tag is already in the list it is removed, otherwise it is added.
  def toggle(*names)
    extract_and_apply_options!(names)
    
    names.each do |name|
      include?(name) ? delete(name) : push(name)
    end
    
    clean! 
    self
  end
  
  ***REMOVED*** Transform the tag_list into a tag string suitable for edting in a form.
  ***REMOVED*** The tags are joined with <tt>TagList.delimiter</tt> and quoted if necessary.
  ***REMOVED***
  ***REMOVED***   tag_list = TagList.new("Round", "Square,Cube")
  ***REMOVED***   tag_list.to_s ***REMOVED*** 'Round, "Square,Cube"'
  def to_s
    clean!
    
    map do |name|
      name.include?(delimiter) ? "\"***REMOVED***{name}\"" : name
    end.join(delimiter.ends_with?(" ") ? delimiter : "***REMOVED***{delimiter} ")
  end
  
 private
  ***REMOVED*** Remove whitespace, duplicates, and blanks.
  def clean!
    reject!(&:blank?)
    map!(&:strip)
    uniq!
  end
  
  def extract_and_apply_options!(args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.assert_valid_keys :parse
    
    if options[:parse]
      args.map! { |a| self.class.from(a) }
    end
    
    args.flatten!
  end
  
  class << self
    ***REMOVED*** Returns a new TagList using the given tag string.
    ***REMOVED*** 
    ***REMOVED***   tag_list = TagList.from("One , Two,  Three")
    ***REMOVED***   tag_list ***REMOVED*** ["One", "Two", "Three"]
    def from(source)
      tag_list = new
      
      case source
      when Array
        tag_list.add(source)
      else
        string = source.to_s.dup
        
        ***REMOVED*** Parse the quoted tags
        [
          /\s****REMOVED***{delimiter}\s*(['"])(.*?)\1\s*/,
          /^\s*(['"])(.*?)\1\s****REMOVED***{delimiter}?/
        ].each do |re|
          string.gsub!(re) { tag_list << $2; "" }
        end
        
        tag_list.add(string.split(delimiter))
      end
      
      tag_list
    end
  end
end
