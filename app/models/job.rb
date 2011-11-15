require 'will_paginate/array'

class Job < ActiveRecord::Base

  # === List of columns ===
  #   id                  : integer 
  #   user_id             : integer 
  #   title               : string 
  #   desc                : text 
  #   category_id         : integer 
  #   num_positions       : integer 
  #   paid                : boolean 
  #   credit              : boolean 
  #   created_at          : datetime 
  #   updated_at          : datetime 
  #   department_id       : integer 
  #   activation_code     : integer 
  #   active              : boolean 
  #   delta               : boolean 
  #   earliest_start_date : datetime 
  #   latest_start_date   : datetime 
  #   end_date            : datetime 
  #   compensation        : string 
  #   open                : boolean 
  # =======================

  include AttribsHelper

  ##################
  #  ASSOCIATIONS  #
  ##################

  belongs_to :user
  belongs_to :department
  has_and_belongs_to_many :categories
  has_many :pictures
  
  has_many :watches
  has_many :applics
  #has_many :applicants, :class_name => 'User', :through => :applics
  has_many :applicants, :through => :applics, :source => :user
  has_many :users, :through => :watches
  has_many :sponsorships, :dependent => :destroy
  has_many :faculties, :through => :sponsorships
  has_many :coursereqs, :dependent => :destroy
  has_many :courses, :through => :coursereqs
  has_many :proglangreqs, :dependent => :destroy
  has_many :proglangs, :through => :proglangreqs
  
  #################
  #  VALIDATIONS  #
  #################

  validates_presence_of :title, :desc, :department
  
  # Validates that end dates are no earlier than right now.
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

  ##########
  # Scopes #
  ##########

  scope :active, lambda { where(:active => true) }
 
  attr_accessor :category_names
  attr_accessor :course_names
  attr_accessor :proglang_names
  
  # If true, handle_categories, handle_courses, and handle_proglangs don't do anything. 
  # The purpose of this is so that in activating a job, these data aren't lost.
  @skip_handlers = false
  attr_accessor :skip_handlers
  
  @skip_validate_sponsorships = false
  attr_accessor :skip_validate_sponsorships
  
  acts_as_taggable

  #############
  #  METHODS  #
  #############

  def self.active_jobs
    Job.find(:all, :conditions => {:active => true}, :order => "created_at DESC")
  end
  
  def self.smartmatches_for(my, limit=4) # matches for a user
    list_separator = ','        # string that separates items in the stored list
    
    query = []
    [my.course_list_of_user,
     my.category_list_of_user,
     my.proglang_list_of_user].each do |list|
      query << list.split(list_separator)
    end

    # magic
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
  
  # This is the main search handler.
  # It should be the ONLY interface between search queries and jobs;
  # hopefully this will make the choice of search engine transparent
  # to our app.
  #
  # By default, it finds an unlimited number of active and non-ended jobs.
  # You can also restrict by query, department, faculty, paid, credit,
  # and set a limit of max number of results.
  #
  # query: Array or string of search terms.
  # extra_options: Hash of additional options:
  #   - included_ended: if false, don't include ended jobs
  #   - department_id: ID of department you want to search, or 0 for all depts
  #   - faculty: ID of faculty member you want to search, or 0 for all
  #   - compensation: can be "Paid Only", "Credit Only", or "Paid and Credit"
  #   - limit: max. number of results, or 0 for no limit
  #   - tags: array of tag strings to match (searches only tags and not body, title, etc.)
  #   - order: ARRAY of custom sorting conditions, besides @relevance. Conditions concatenated left to right.
  #   - include_inactive: if true, include inactive jobs
  #
  def self.find_jobs(query=nil, options={})
    throw "Query must be a string" unless query.nil? || query.is_a?(String)

    # Sanitize input
    query ||= ""
    query = query.gsub(/\\/, '\\\\\\\\').gsub(/%/, '\%').gsub(/_/, '\_')
    query = "%" + query + "%"
    
    # needed?
    options[:tags] = [*options[:tags]]

    jobs = Job.arel_table
    faculties = Faculty.arel_table
    departments = Department.arel_table

    results = Job.select("distinct jobs.*").joins(:faculties).joins(:department)
                 .where(jobs[:title].matches(query)
                        .or(jobs[:desc].matches(query))
                        .or(faculties[:name].matches(query))
                        .or(departments[:name].matches(query))
                        )
                 
    results = results.where(jobs[:end_date].gt(Time.now).or(jobs[:end_date].eq(nil))) unless options[:include_ended]
    results = results.where(departments[:id].eq(options[:department_id])) if options[:department_id]
    results = results.where(faculties[:id].eq(options[:faculty_id])) if options[:faculty_id]
    results = results.where(jobs[:paid].eq(true)) if options[:compensation] == "Paid Only"
    results = results.where(jobs[:credit].eq(true)) if options[:compensation] == "Credit Only"
    results = results.limit(options[:limit]) if options[:limit]
    order = options[:order] || "created_at DESC"
    results = results.order(order)
    results = results.where(jobs[:active].eq(true)) unless options[:include_inactive]
    
    # results = results.tagged_with(options[:tags]) if options[:tags].present?
    
    page = options[:page] || 1
    per_page = options[:per_page] || 16
    return results.all.paginate(:page => page, :per_page => per_page)
    
  end # find_jobs

  def self.query_url(options)
    params = {}
    params[:query]          = options[:query]               if options[:query]
    params[:department]     = options[:department_id]       if options[:department_id] and Department.exists?(options[:department_id])
    params[:paid]           = true                          if options[:paid]
    params[:credit]         = true                          if options[:credit]
    url_for(:controller => 'jobs', :only_path=>true)+"?#{params.collect { |param, value| param+'='+value }.join('&')}"
  end
   
  def self.find_recently_added(n)
  #Job.find(:all, {:order => "created_at DESC", :limit=>n, :active=>true} )
    Job.find_jobs( :extra_conditions => {:order=>"created_at DESC", :limit=>n} )
  end

  def self.human_attribute_name(attr, options = {})
    if attr == :desc
      return "Description"
    end
    return super
  end
  
  # Returns a string containing the category names taken by this Job
  # e.g. "robotics,signal processing"
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
  
  # Returns a string containing the 'required course' names taken by this Job
  # e.g. "CS61A,CS61B"
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
  
  # Returns a string containing the 'desired proglang' names taken by this Job
  # e.g. "java,scheme,c++"
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
  
  # Ensures all fields are valid
  def mend
    # Check for deleted/bad faculty
    if not self.faculties.empty? and not Faculty.exists?(self.faculties.first.id)
        self.faculties = []
    end
  end
  
  # Returns true if the specified user has admin rights (can view applications,
  # edit, etc.) for this job.
  def allow_admin_by?(u)
    self.user == u or self.faculties.include?(u)
  end

  # Perform validations without sponsorships. Used to determine whether to create a sponsorship later on.
  def valid_without_sponsorships?
    svs = @skip_validate_sponsorships
    @skip_validate_sponsorships = true
    retval = valid?
    @skip_validate_sponsorships = svs
    retval
  end
  
  # Makes the job not active, and reassigns it an activation code.
  # Used when creating a job or if, when updating the job, a new 
  #   faculty sponsor is specified.
  def reset_activation(send_email = false)
    self.active = false
    self.activation_code = ActiveSupport::SecureRandom.random_number(10e6.to_i)

    # Save, skipping validations, so that we just change the activation code
    # and leave the rest alone! (Also so that we don't encounter weird bugs with
    # activating jobs whose end dates are in the past, etc.)
    self.save(:validate => false)

    if send_email
      # Send the email for activation.
      begin
        JobMailer.activate_job_email(self).deliver
      rescue => e
        Rails.logger.error "Failed to send activation mail for job##{self.id}: #{e.inspect}"
        raise if Rails.development?
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
