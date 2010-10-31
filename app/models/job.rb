class Job < ActiveRecord::Base
  belongs_to :user
  belongs_to :department
  has_and_belongs_to_many :categories
  has_many :pictures
  
  has_many :watches
  has_many :applics
  ***REMOVED***has_many :applicants, :class_name => 'User', :through => :applics
  has_many :applicants, :through => :applics, :source => :user
  has_many :users, :through => :watches
  has_many :sponsorships
  has_many :faculties, :through => :sponsorships
  has_many :coursereqs
  has_many :courses, :through => :coursereqs
  has_many :proglangreqs
  has_many :proglangs, :through => :proglangreqs
  
  ***REMOVED*** Before carrying out validations and creating the actual object, 
  ***REMOVED*** handle the name of the category(ies), the required courses, and the 
  ***REMOVED*** desired proglangs so as to deal with associations properly.
  before_validation :handle_categories
  before_validation :handle_courses
  before_validation :handle_proglangs
  
  validates_presence_of :title, :desc, :exp_date, :num_positions, :department
  
  ***REMOVED*** Validates that expiration dates are no earlier than right now.
  validates_each :exp_date do |record, attr, value|
	record.errors.add attr, 'Expiration date cannot be earlier than right now.' if value < Time.now - 1.hour
  end
  
  validates_length_of :title, :within => 10..200
  validates_numericality_of :num_positions
  validate :validate_sponsorships
  
  
  attr_accessor :category_names
  attr_accessor :course_names
  attr_accessor :proglang_names
  
  ***REMOVED*** If true, handle_categories, handle_courses, and handle_proglangs don't do anything. 
  ***REMOVED*** The purpose of this is so that in activating a job, these data aren't lost.
  @skip_handlers = false
  attr_accessor :skip_handlers
  
  acts_as_taggable
  acts_as_xapian :texts => [:title, :desc, :tag_list],
    :values => [
        [:paid,             0, "paid",          :number],
        [:credit,           1, "credit",        :number],
        [:exp_date,         2, "exp_date",      :date],
        [:active,           3, "active",        :number],
        [:updated_at,       4, "updated_at",    :date],
        [:department_id,    5, "department_id", :number],
        [:num_positions,    6, "num_positions", :number]
    ]
  ***REMOVED***xapit do |index|
    ***REMOVED***index.text :title, :desc, :tag_list
    ***REMOVED***index.field :active, :paid, :credit
    ***REMOVED***index.sortable :exp_date
  ***REMOVED***end
  
  def self.active_jobs
    Job.find(:all, :conditions => {:active => true}, :order => "created_at DESC")
  end
  
  def self.smartmatches_for(my, limit=4) ***REMOVED*** matches for a user
	***REMOVED*** courses = my.course_list_of_user.gsub ",", " "
  	***REMOVED*** cats = my.category_list_of_user.gsub ",", " "
  	***REMOVED*** pls = my.proglang_list_of_user.gsub ",", " "
  	***REMOVED*** query = "***REMOVED***{cats} ***REMOVED***{courses} ***REMOVED***{pls}"
    ***REMOVED***Job.find_jobs(query, {:limit=>limit, :exclude_expired=>true})
    
    
    list_separator = ","        ***REMOVED*** string that separates items in the stored list
    
    query = []
    [my.course_list_of_user,
     my.category_list_of_user,
     my.proglang_list_of_user].each do |list|
        query.concat list.split(list_separator)
    end
    Job.find_jobs(query, {:operator=>:OR, :exclude_expired=>true})
    ***REMOVED*** TODO: limit
  end
  
  ***REMOVED*** This is the main search handler.
  ***REMOVED*** It should be the ONLY interface between search queries and jobs;
  ***REMOVED*** hopefully this will make the choice of search engine transparent
  ***REMOVED*** to our app.
  ***REMOVED***
  ***REMOVED*** By default, it finds an unlimited number of active and non-expired jobs.
  ***REMOVED*** You can also restrict by query, department, faculty, paid, credit,
  ***REMOVED*** and set a limit of max number of results.
  ***REMOVED***
  ***REMOVED*** Currently uses Xapian/xapit
  ***REMOVED***   (http://github.com/ryanb/xapit***REMOVED***readme)
  ***REMOVED***   windows binaries from (http://www.flax.co.uk/xapian_binaries)
  ***REMOVED***
  ***REMOVED*** query: Array of search terms.
  ***REMOVED*** extra_options: Hash of additional options:
  ***REMOVED***   - exclude_expired: if true, don't include expired jobs
  ***REMOVED***   - department: ID of department you want to search, or 0 for all depts
  ***REMOVED***   - faculty: ID of faculty member you want to search, or 0 for all
  ***REMOVED***   - paid: if true, return jobs that have paid=true; else return paid and nonpaid
  ***REMOVED***   - credit: if true, return jobs that have credit=true; else return credit and noncredit
  ***REMOVED***   - limit: max. number of results, or 0 for no limit
  ***REMOVED***   - conditions: more raw SQL conditions. Be careful with this.
  ***REMOVED***   - operator: [:AND | :OR], search operator used to join query terms
  ***REMOVED***
  def self.find_jobs(query=[], extra_options={})
    ***REMOVED*** Sanitize some boolean options to avoid false positives.
    ***REMOVED*** This happens in situations like paid=0 => paid=true
    [:paid, :credit].each do |attrib|
        extra_options[attrib] = from_binary(extra_options[attrib])
    end
    
    ***REMOVED*** Set up default options, and merge the extras
    options = { :exclude_expired    => true,        ***REMOVED*** return expired jobs too
                :department         => 0,           ***REMOVED*** department ID
                :faculty            => 0,           ***REMOVED*** faculty ID
                :paid               => false,       ***REMOVED*** paid?
                :credit             => false,       ***REMOVED*** credit?
                :limit              => 0,           ***REMOVED*** max. num results
                :conditions         => {},          ***REMOVED*** more SQL conditions
                :operator           => :AND,        ***REMOVED*** search operator <:AND | :OR>
                }.update(extra_options)
                
    ***REMOVED*** ohai
    conditions = {}
    conditions[:active]     = true
    conditions[:exp_date]   = Time.at(0)..Time.now  unless options[:exclude_expired]
    conditions[:paid]       = true                  if options[:paid]
    conditions[:credit]     = true                  if options[:credit]

    ***REMOVED*** Choose an operator from the list; i.e. sanitize the operator.
    op = [:AND, :OR].detect {|o| o==options[:operator]} || :AND
    opstring = op.to_s+" "
    
    queryoptions = []
    queryoptions << "active:1"                      if options[:exclude_expired]
    queryoptions << "department:***REMOVED***{department}"      if options[:department] != 0
    queryoptions << "paid:1"                        if options[:paid]
    queryoptions << "credit:1"                      if options[:credit]
    
    querystring = ""
    querystring += query.join(opstring) unless query.empty?
    querystring += " AND (***REMOVED***{queryoptions.join(" AND ")})" unless queryoptions.empty?
    
    ***REMOVED***jobs = Job.search(query.join(opstring), :conditions => conditions)
    jobs = ActsAsXapian::Search.new([Job], querystring)
  end
  
  def self.find_jobs_OLD(query={}, extra_options={ })
    ***REMOVED*** Sanitize some boolean options to avoid false positives.
    ***REMOVED*** This happens in situations like paid=0 => paid=true
    [:paid, :credit].each do |attrib|
        extra_options[attrib] = from_binary(extra_options[attrib])
    end
    
    ***REMOVED*** Set up default options, and merge the extras
    options = { :exclude_expired    => true,        ***REMOVED*** return expired jobs too
                :department         => 0,           ***REMOVED*** department ID
                :faculty            => 0,           ***REMOVED*** faculty ID
                :paid               => false,       ***REMOVED*** paid?
                :credit             => false,       ***REMOVED*** credit?
                :limit              => 0,           ***REMOVED*** max. num results
                :conditions         => {},          ***REMOVED*** more SQL conditions
                :operator           => :AND,        ***REMOVED*** search operator <:AND | :OR>
                }.update(extra_options)

    ***REMOVED*** Choose an operator from the list; i.e. sanitize the operator.
    op = [:AND, :OR].detect {|o| o==options[:operator]} || :AND
    opstring = op.to_s+" "
                
    ***REMOVED*** Build conditions. Job must [optionally]:
    ***REMOVED***  - be active
    ***REMOVED***  - expire in the future
    ***REMOVED***  - [match requested department]
    ***REMOVED***  - [be paid]
    ***REMOVED***  - [be credit]
    
    ***REMOVED*** These are the necessary conditions. Jobs MUST be active and non-expired (unless we really want
    ***REMOVED*** to exclude the expired ones.. but you get the idea).
    conditions = "(active='t'"
    conditions += " AND exp_date > '***REMOVED***{Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")}'" if options[:exclude_expired]
    conditions += ")"
    
    ***REMOVED*** These are the optional conditions.
    moar_conditions = []
    moar_conditions << "department_id=***REMOVED***{department}"     if options[:department] != 0
    moar_conditions << "paid='t'"                        if options[:paid]
    moar_conditions << "credit='t'"                      if options[:credit]
    
    ***REMOVED*** Concat the optional conditions onto the necessary ones
    conditions += " AND (***REMOVED***{moar_conditions.join(opstring)})" if moar_conditions.length > 0
    
    ***REMOVED*** Merge additional SQL conditions
    if options[:conditions].is_a? String then
        conditions += " AND "+options[:conditions]
    else options[:conditions].each do |key, value|
        conditions += " AND ***REMOVED***{key}=***REMOVED***{value}"
        end
    end

    ***REMOVED*** Find results matching search criteria
    ***REMOVED*** Also apply a result limit, if any
    results = {}
    find_args = {:conditions=>conditions}
    find_args.update( {:limit=>options[:limit]} ) if options[:limit] > 0
    if (query and !query.empty?)
        results = Job.with_query(query.join(opstring)).find(:all, find_args)
      else
        results = Job.find(:all, find_args)
    end
    
    ***REMOVED*** Filter by requested faculty
    ***REMOVED*** TODO: do this in the database
    results = results.select {|j| j.faculties.collect{|f| f.id.to_i}.include?(options[:faculty]) }  if options[:faculty] != 0
    return results
  end
   
  def self.find_recently_added(n)
	***REMOVED***Job.find(:all, {:order => "created_at DESC", :limit=>n, :active=>true} )
    Job.find_jobs( :extra_conditions => {:order=>"created_at DESC", :limit=>n} )
  end
  
  ***REMOVED*** Returns a string containing the category names taken by job @job
  ***REMOVED*** e.g. "robotics,signal processing"
  def category_list_of_job
  	category_list = ''
  	categories.each do |cat|
  		category_list << cat.name + ','
  	end
  	category_list[0..(category_list.length - 2)].downcase
  end
  
  ***REMOVED*** Returns a string containing the 'required course' names taken by job @job
  ***REMOVED*** e.g. "CS61A,CS61B"
  def course_list_of_job
  	course_list = ''
  	courses.each do |c|
  		course_list << c.name + ','
  	end
  	course_list[0..(course_list.length - 2)].upcase
  end
  
  ***REMOVED*** Returns a string containing the 'desired proglang' names taken by job @job
  ***REMOVED*** e.g. "java,scheme,c++"
  def proglang_list_of_job
  	proglang_list = ''
  	proglangs.each do |pl|
  		proglang_list << pl.name + ','
  	end
  	proglang_list[0..(proglang_list.length - 2)].downcase
  end
  
  ***REMOVED*** Returns the activation url for this job
  def activation_url
    "***REMOVED***{$rm_root}jobs/activate/***REMOVED***{self.id}?a=***REMOVED***{self.activation_code}"
  end
  
  protected
  
  	***REMOVED*** Parses the textbox list of category names from "Signal Processing, Robotics"
	***REMOVED*** etc. to an enumerable object categories
	def handle_categories
		unless skip_handlers
			self.categories = []  ***REMOVED*** eliminates any previous categories_jobs so as to avoid duplicates
			category_array = []
			category_array = category_names.split(',').uniq if ! category_names.nil?
			category_array.each do |item|
				self.categories << Category.find_or_create_by_name(item.downcase.strip)
			end
		end
	end
	
	***REMOVED*** Parses the textbox list of courses from "CS162,CS61A,EE123"
	***REMOVED*** etc. to an enumerable object courses
	def handle_courses
		unless skip_handlers
			self.courses = []  ***REMOVED*** eliminates any previous enrollments so as to avoid duplicates
			course_array = []
			course_array = course_names.split(',').uniq if ! course_names.nil?
			course_array.each do |item|
				self.courses << Course.find_or_create_by_name(item.upcase.strip)
			end
		end
	end
	
	***REMOVED*** Parses the textbox list of proglangs from "java,c,scheme"
	***REMOVED*** etc. to an enumerable object proglangs
	def handle_proglangs
		unless skip_handlers
			self.proglangs = []  ***REMOVED*** eliminates any previous enrollments so as to avoid duplicates
			proglang_array = []
			proglang_array = proglang_names.split(',').uniq if ! proglang_names.nil?
			proglang_array.each do |pl|
				self.proglangs << Proglang.find_or_create_by_name(pl.downcase.strip)
			end
		end
	end	
	
	def validate_sponsorships
	  errors.add_to_base("Job posting must have at least one faculty sponsor.") unless (sponsorships.size > 0)
	end

	
end
