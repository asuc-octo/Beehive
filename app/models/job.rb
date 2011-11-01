class Job < ActiveRecord::Base

  ***REMOVED*** === List of columns ===
  ***REMOVED***   id                  : integer 
  ***REMOVED***   user_id             : integer 
  ***REMOVED***   title               : string 
  ***REMOVED***   desc                : text 
  ***REMOVED***   category_id         : integer 
  ***REMOVED***   num_positions       : integer 
  ***REMOVED***   paid                : boolean 
  ***REMOVED***   credit              : boolean 
  ***REMOVED***   created_at          : datetime 
  ***REMOVED***   updated_at          : datetime 
  ***REMOVED***   department_id       : integer 
  ***REMOVED***   activation_code     : integer 
  ***REMOVED***   active              : boolean 
  ***REMOVED***   delta               : boolean 
  ***REMOVED***   earliest_start_date : datetime 
  ***REMOVED***   latest_start_date   : datetime 
  ***REMOVED***   end_date            : datetime 
  ***REMOVED*** =======================

  include AttribsHelper

  ***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
  ***REMOVED***  ASSOCIATIONS  ***REMOVED***
  ***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***

  belongs_to :user
  belongs_to :department
  has_and_belongs_to_many :categories
  has_many :pictures
  
  has_many :watches
  has_many :applics
  ***REMOVED***has_many :applicants, :class_name => 'User', :through => :applics
  has_many :applicants, :through => :applics, :source => :user
  has_many :users, :through => :watches
  has_many :sponsorships, :dependent => :destroy
  has_many :faculties, :through => :sponsorships
  has_many :coursereqs, :dependent => :destroy
  has_many :courses, :through => :coursereqs
  has_many :proglangreqs, :dependent => :destroy
  has_many :proglangs, :through => :proglangreqs
  
  ***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
  ***REMOVED***  VALIDATIONS  ***REMOVED***
  ***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***

  validates_presence_of :title, :desc, :department
  
  ***REMOVED*** Validates that end dates are no earlier than right now.
  validates_each :end_date do |record, attr, value|
    record.errors.add attr, 'cannot be earlier than right now' if
      value.present? && (value < Time.now - 1.hour)
  end

  validates_length_of :title, :within => 10..200
  validates_length_of :desc, :within => 10..20000
  validates_numericality_of :num_positions, :greater_than_or_equal_to => 0,
    :allow_nil => true
  validate :validate_sponsorships, :unless => Proc.new{|j|j.skip_validate_sponsorships}
  validate :earliest_start_date_must_be_before_latest
  validate :latest_start_date_must_be_before_end_date
 
  attr_accessor :category_names
  attr_accessor :course_names
  attr_accessor :proglang_names
  
  ***REMOVED*** If true, handle_categories, handle_courses, and handle_proglangs don't do anything. 
  ***REMOVED*** The purpose of this is so that in activating a job, these data aren't lost.
  @skip_handlers = false
  attr_accessor :skip_handlers
  
  @skip_validate_sponsorships = false
  attr_accessor :skip_validate_sponsorships
  
  acts_as_taggable

  ***REMOVED*** ThinkingSphinx
  define_index do
    indexes :title
    indexes :desc
    indexes tags(:name),       :as => :tag_names,     :facet => true
    indexes department(:name), :as => :department,    :facet => true
    indexes faculties(:name),  :as => :faculty,       :facet => true
    
    has :active
    has :paid
    has :credit
    has :created_at
    has :updated_at
    has :end_date
    has :num_positions
    has department(:id),  :as => :department_id
    has faculties(:id),   :as => :faculty_ids
    
    set_property :delta => true
  end

  sphinx_scope(:tagged_with) do |tags|
    tags = tags.collect {|t| t.is_a?(Tag) ? t.name : t.to_s}
    {:conditions=>{:tag_names=>tags}, :match_mode=>:extended}
  end

  ***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
  ***REMOVED***  METHODS  ***REMOVED***
  ***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***

  def self.active_jobs
    Job.find(:all, :conditions => {:active => true}, :order => "created_at DESC")
  end
  
  def self.smartmatches_for(my, limit=4) ***REMOVED*** matches for a user
    list_separator = ','        ***REMOVED*** string that separates items in the stored list
    
    query = []
    [my.course_list_of_user,
     my.category_list_of_user,
     my.proglang_list_of_user].each do |list|
      query << list.split(list_separator)
    end

    ***REMOVED*** magic
    smartmatch_ranker = "@weight"

    qu = query.join(list_separator).chomp(list_separator)
    opts = {:match_mode=>:any, :limit=>limit, :custom_rank=>smartmatch_ranker,
        :rank_mode=>:bm25}

    puts "\n\n\n" + qu.inspect+ "\n\n\n"
    puts "\n\n\n" + opts.inspect + "\n\n\n"
    Job.find_jobs(qu, opts)
  end

  def open_ended_end_date
    end_date.blank?
  end
  
  ***REMOVED*** This is the main search handler.
  ***REMOVED*** It should be the ONLY interface between search queries and jobs;
  ***REMOVED*** hopefully this will make the choice of search engine transparent
  ***REMOVED*** to our app.
  ***REMOVED***
  ***REMOVED*** By default, it finds an unlimited number of active and non-ended jobs.
  ***REMOVED*** You can also restrict by query, department, faculty, paid, credit,
  ***REMOVED*** and set a limit of max number of results.
  ***REMOVED***
  ***REMOVED*** Currently uses Sphinx/ThinkingSphinx
  ***REMOVED***
  ***REMOVED*** query: Array or string of search terms.
  ***REMOVED*** extra_options: Hash of additional options:
  ***REMOVED***   - exclude_ended: if true, don't include ended jobs
  ***REMOVED***   - department: ID of department you want to search, or 0 for all depts
  ***REMOVED***   - faculty: ID of faculty member you want to search, or 0 for all
  ***REMOVED***   - paid: if true, return jobs that have paid=true; else return paid and nonpaid
  ***REMOVED***   - credit: if true, return jobs that have credit=true; else return credit and noncredit
  ***REMOVED***   - limit: max. number of results, or 0 for no limit
  ***REMOVED***   - match_mode: [:any | :all | :extended], sets match mode. Default :any.
  ***REMOVED***   - tags: array of tag strings to match (searches only tags and not body, title, etc.)
  ***REMOVED***   - order: ARRAY of custom sorting conditions, besides @relevance. Conditions concatenated left to right.
  ***REMOVED***
  def self.find_jobs(query=nil, options={})
    throw "Query must be a string" unless query.nil? || query.is_a?(String)

    ***REMOVED*** Sanitize input
    query ||= ""
    query.gsub! /[^a-zA-Z0-9 ,]/, ''
    options[:tags] = [*options[:tags]]

    ***REMOVED*** Sanitize some boolean options to avoid false positives.
    ***REMOVED*** This happens in situations like paid=0 => paid=true
    [:paid, :credit].each do |attrib|
        options[attrib] = from_binary(options[attrib])
    end
    
    query = "%" + query + "%"
    end_date = options[:exclude_ended] ? Time.at(1) : Time.now
    
    jobs = Job.arel_table
    faculties = Faculty.arel_table
    sponsorships = Sponsorship.arel_table
    
    results = Job.joins(:sponsorships).where(jobs[:id].eq(sponsorships[:job_id]))
                 .joins(:faculties).where(faculties[:id].eq(sponsorships[:faculty_id]))
                 .where(jobs[:active].eq(true))
                 .where(jobs[:end_date].gt(end_date).or(jobs[:end_date].eq(nil)))
                 .where(jobs[:desc].matches(query).or(jobs[:title].matches(query)).or(faculties[:name].matches(query)))


    ***REMOVED*** puts results.to_sql
    ***REMOVED*** puts "*" * 100
    ***REMOVED*** for j in results
      ***REMOVED*** puts j.title
    ***REMOVED*** end
    
    return results

    ***REMOVED*** Common conditions
    ts_common_options = {}
    ts_common_options[:max_matches]    = options[:limit] if options[:limit].present? && options[:limit] > 0
    ts_common_options[:page]         ||= options[:page]
    ts_common_options[:per_page]     ||= options[:per_page]
    ts_common_options[:rank_mode]      = :proximity_bm25

    ***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
    ***REMOVED*** ALL conditions ***REMOVED***
    ***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
    ts_options = { :conditions => {}, :with => {}, :without => {} }
    ts_options[:with][:active]        = true
    ts_options[:with][:paid]          = true if options[:paid]
    ts_options[:with][:credit]        = true if options[:credit]
    ts_options[:with][:faculty_ids]   = [options[:faculty_id].to_i]   if options[:faculty_id].present? && Faculty.exists?(options[:faculty_id])
    ts_options[:with][:department_id] = options[:department_id].to_i  if options[:department_id].present? && Department.exists?(options[:department_id])
    ***REMOVED***ts_options[:with][:end_date]      = (Time.now .. 100.years.since) unless options[:ended]

    ts_options[:without][:end_date]    = (Time.at(1) .. Time.now)  unless options[:ended]
      ***REMOVED*** Implementation detail: Sphinx indexes nil times as 0, so search from (0, now]
    ts_options[:without][:num_positions] = -1 unless options[:filled]
      ***REMOVED*** Assume -1, not 0, means it's filled.

    ts_options[:match_mode] = :extended
    ts_options.update(ts_common_options)

    results = Job.search query, ts_options

    ***REMOVED*** Final filters
    results = results.tagged_with(options[:tags]) if options[:tags].present?
    
    return results
  end ***REMOVED*** find_jobs


  def self.find_jobs_ASDF(query, extra_options={})
    ***REMOVED*** Sanitize some boolean options to avoid false positives.
    ***REMOVED*** This happens in situations like paid=0 => paid=true
    [:paid, :credit].each do |attrib|
        extra_options[attrib] = from_binary(extra_options[attrib])
    end
    
    ***REMOVED*** Handle weird cases with bad query
    query = query.join(' ') if query.kind_of? Array
    
    ***REMOVED*** Default options
    options = {
        :exclude_ended          => true,
        :paid                   => false,
        :credit                 => false,
        :faculty                => 0,
        :match_mode             => :any,
        :limit                  => 0,
        :tags                   => [],
        :custom_rank            => ""
        }.update(extra_options)

    ts_options = {
        :match_mode     => :any,
        :sort_mode      => :extended,
        :order          => "@relevance DESC, end_date ASC",
        :rank_mode      => :proximity_bm25
        }
    
    ***REMOVED*** Selectively build conditions
    ts_conditions = {}
    ts_conditions[:active]      = true
    ts_conditions[:end_date]    = Time.now..100.years.since unless options[:exclude_ended]
    ts_conditions[:paid]        = true              if options[:paid]
    ts_conditions[:credit]      = true              if options[:credit]
    ts_conditions[:sponsor_id]  = options[:faculty] if options[:faculty] > 0 and Faculty.exists?(options[:faculty])
    ***REMOVED***ts_conditions[:tag_names]   = options[:tags].split(/[\s,]+/)    unless options[:tags].blank?
    
    ***REMOVED*** Custom parsing
    options[:tags] = options[:tags].split(/[\s,]+/) unless options[:tags].blank?

    ***REMOVED*** Selectively build options
    ts_options[:match_mode]     = options[:match_mode] if [:all, :any, :extended].include? options[:match_mode]
    ts_options[:max_matches]    = options[:limit]   if options[:limit] > 0
    ts_options[:rank_mode]      = options[:rank_mode] if [:proximity_bm25, :bm25, :wordcount].include? options[:rank_mode]
    ts_options[:page]           ||= options[:page]
    ts_options[:per_page]       ||= options[:per_page]
    ts_options[:field_weights]  = {:tag_names=>150}
   
    if options[:custom_rank] && !options[:custom_rank].empty?
        ts_options[:sort_mode] = :expr
        ts_options[:order]     = options[:custom_rank]
    end
    
    ***REMOVED*** Do the search
    results = Job
    results = Job.search query, {:conditions => ts_conditions}.update(ts_options)
    results = results.tagged_with(options[:tags]) if options[:tags].present?
    return results
  end
 
  def self.query_url(options)
    params = {}
    params[:query]          = options[:query]               if options[:query]
    params[:department]     = options[:department_id]       if options[:department_id] and Department.exists?(options[:department_id])
    params[:paid]           = true                          if options[:paid]
    params[:credit]         = true                          if options[:credit]
    url_for(:controller => 'jobs', :only_path=>true)+"?***REMOVED***{params.collect { |param, value| param+'='+value }.join('&')}"
  end
   
  def self.find_recently_added(n)
  ***REMOVED***Job.find(:all, {:order => "created_at DESC", :limit=>n, :active=>true} )
    Job.find_jobs( :extra_conditions => {:order=>"created_at DESC", :limit=>n} )
  end

  def self.human_attribute_name(attr, options = {})
    if attr == :desc
      return "Description"
    end
    return super
  end
  
  ***REMOVED*** Returns a string containing the category names taken by this Job
  ***REMOVED*** e.g. "robotics,signal processing"
  def category_list_of_job(add_spaces = false)
    category_list = ''
    self.categories.each do |cat|
      category_list << cat.name + ','
      category_list << ' ' if add_spaces
    end
    
    if add_spaces
      return category_list[0..(category_list.length - 3)].downcase
    else
      return category_list[0..(category_list.length - 2)].downcase
    end
  end
  
  ***REMOVED*** Returns a string containing the 'required course' names taken by this Job
  ***REMOVED*** e.g. "CS61A,CS61B"
  def course_list_of_job(add_spaces = false)
    course_list = ''
    self.courses.each do |c|
      course_list << c.name + ','
      course_list << ' ' if add_spaces
    end
    
    if add_spaces
      return course_list[0..(course_list.length - 3)].upcase
    else
      return course_list[0..(course_list.length - 2)].upcase
    end
  end
  
  ***REMOVED*** Returns a string containing the 'desired proglang' names taken by this Job
  ***REMOVED*** e.g. "java,scheme,c++"
  def proglang_list_of_job(add_spaces = false)
    proglang_list = ''
    self.proglangs.each do |pl|
      proglang_list << pl.name.capitalize + ','
      proglang_list << ' ' if add_spaces
    end
    
    if add_spaces
      return proglang_list[0..(proglang_list.length - 3)]
    else
      return proglang_list[0..(proglang_list.length - 2)]
    end
  end
  
  ***REMOVED*** Ensures all fields are valid
  def mend
    ***REMOVED*** Check for deleted/bad faculty
    if not self.faculties.empty? and not Faculty.exists?(self.faculties.first.id)
        self.faculties = []
    end
  end
  
  ***REMOVED*** Returns true if the specified user has admin rights (can view applications,
  ***REMOVED*** edit, etc.) for this job.
  def allow_admin_by?(u)
    self.user == u or self.faculties.include?(u)
  end

  ***REMOVED*** Perform validations without sponsorships. Used to determine whether to create a sponsorship later on.
  def valid_without_sponsorships?
    svs = @skip_validate_sponsorships
    @skip_validate_sponsorships = true
    retval = valid?
    @skip_validate_sponsorships = svs
    retval
  end
  
  ***REMOVED*** Makes the job not active, and reassigns it an activation code.
  ***REMOVED*** Used when creating a job or if, when updating the job, a new 
  ***REMOVED***   faculty sponsor is specified.
  def reset_activation(send_email = false)
    self.active = false
    self.activation_code = ActiveSupport::SecureRandom.random_number(10e6.to_i)
    ***REMOVED*** don't have id at this point     ***REMOVED***(@job.id * 10000000) + (rand(99999) + 100000) ***REMOVED*** Job ID appended to a random 6 digit number.

    puts "[][][] ACTIVATION CODE: " + self.activation_code.to_s

    ***REMOVED*** Save, skipping validations, so that we just change the activation code
    ***REMOVED*** and leave the rest alone! (Also so that we don't encounter weird bugs with
    ***REMOVED*** activating jobs whose end dates are in the past, etc.)
    self.save(:validate => false)

    if send_email
      ***REMOVED*** Send the email for activation.
      begin
        JobMailer.activate_job_email(self).deliver
      rescue => e
        Rails.logger.error "Failed to send activation mail for job***REMOVED******REMOVED***{self.id}: ***REMOVED***{e.inspect}"
        raise if Rails.env == 'development'
      end
    end
  end

  protected
  
  def validate_sponsorships
    errors.add_to_base("Job posting must have at least one faculty sponsor.") unless (sponsorships.size > 0)
  end

  def earliest_start_date_must_be_before_latest
    errors[:earliest_start_date] << "cannot be later than the latest start date" if 
      latest_start_date.present? && earliest_start_date > latest_start_date
  end

  def latest_start_date_must_be_before_end_date
    errors.add(:latest_start_date, "cannot be later than the end date") if
      latest_start_date.present? && !open_ended_end_date &&
        latest_start_date > end_date
  end

end
