***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: jobs
***REMOVED***
***REMOVED***  id                  :integer          not null, primary key
***REMOVED***  user_id             :integer
***REMOVED***  title               :string(255)
***REMOVED***  desc                :text
***REMOVED***  category_id         :integer
***REMOVED***  num_positions       :integer
***REMOVED***  created_at          :datetime
***REMOVED***  updated_at          :datetime
***REMOVED***  department_id       :integer
***REMOVED***  activation_code     :integer
***REMOVED***  delta               :boolean          default(TRUE), not null
***REMOVED***  earliest_start_date :datetime
***REMOVED***  latest_start_date   :datetime
***REMOVED***  end_date            :datetime
***REMOVED***  compensation        :integer          default(0)
***REMOVED***  status              :integer          default(0)
***REMOVED***  primary_contact_id  :integer
***REMOVED***  project_type        :integer
***REMOVED***

require 'will_paginate/array'

class Job < ActiveRecord::Base

  include AttribsHelper

  module Compensation         ***REMOVED*** bit flags
    None   = 0
    Pay    = 1
    Credit = 2
    Both   = Pay | Credit

    All    = {
      'None'   => None,
      'Pay'    => Pay,
      'Credit' => Credit,
      'Pay and Credit'   => Both
    }
  end

  module Status
    Open = 0
    Filled = 1

    All = {
      'Open' => Open,
      'Closed' => Filled,
    }
  end

  acts_as_taggable

  ***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
  ***REMOVED***  ASSOCIATIONS  ***REMOVED***
  ***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***

  belongs_to :user
  belongs_to :department
  has_many :pictures ***REMOVED*** unused
  has_one :contacter,     :class_name => 'User', :foreign_key => 'id', :primary_key => 'primary_contact_id'
  has_many :owns
  has_many :owners,       :through => :owns, :source => :user
  has_many :sponsorships, :dependent => :destroy
  has_many :faculties,    :through => :sponsorships
  has_many :curations
  has_many :orgs,         :through => :curations

  has_many :coursereqs,   :dependent => :destroy
  has_many :courses,      :through => :coursereqs
  has_many :proglangreqs, :dependent => :destroy
  has_many :proglangs,    :through => :proglangreqs
  has_and_belongs_to_many :categories ***REMOVED*** TODO deprecate in favor of tags

  has_many :watches
  has_many :users,        :through => :watches ***REMOVED*** TODO rename to watchers
  has_many :applics,      :dependent => :destroy
  has_many :applicants,   :through => :applics, :source => :user
  ***REMOVED***has_many :applicants, :class_name => 'User', :through => :applics

  ***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
  ***REMOVED***  VALIDATIONS  ***REMOVED***
  ***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***

  validates_presence_of :title, :desc, :department

  ***REMOVED*** Validates that end dates are no earlier than right now.
  validates_each :end_date do |record, attr, value|
    record.errors.add attr, 'cannot be earlier than right now' if
      value.present? && (value < Time.now - 1.hour)
  end

  validates_numericality_of :num_positions, :greater_than_or_equal_to => 0,
    :allow_nil => true
  validate :earliest_start_date_must_be_before_latest
  validate :latest_start_date_must_be_before_end_date

  validates_inclusion_of :compensation, :in => Compensation::All.values

  ***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
  ***REMOVED*** Scopes ***REMOVED***
  ***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***

 
  attr_accessor :category_names
  attr_accessor :course_names
  attr_accessor :proglang_names
  
  ***REMOVED*** If true, handle_categories, handle_courses, and handle_proglangs don't do anything. 
  ***REMOVED*** The purpose of this is so that in activating a job, these data aren't lost.
  @skip_handlers = false
  attr_accessor :skip_handlers

  ***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
  ***REMOVED***  METHODS  ***REMOVED***
  ***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***

  def project_string
    case project_type
    when 1
      'Undergraduate Research'
    when 2
      'Student Group'
    when 3
      'Design Project'
    else ***REMOVED*** including 4: 'Other'
      ''
    end
  end

  def get_all_project_strings
    return [['Undergraduate Research', 1], ['Student Group', 2], ['Design Project', 3], ['Other', 4]]
  end

  def open?
    status == Job::Status::Open
  end
  def pay?
    (self.compensation & Compensation::Pay) > 0
  end
  def credit?
    (self.compensation & Compensation::Credit) > 0
  end
  def owner?(user)
    self.user == user || owners.include?(user)
  end
  def open_ended_end_date
    end_date.blank?
  end

  ***REMOVED*** Returns true if the specified user has admin rights (can view applications,
  ***REMOVED*** edit, etc.) for this job.
  def can_admin?(user)
    owner?(user) || user.admin?
  end

  ***REMOVED*** @return array of actions the user can take, not including curations
  def actions(user)
    actions = []

    if can_admin?(user)
      actions.push('edit')
      actions.push('delete')
    end

    unless owner?(user)
      applic = applics.find_by_user_id(user) if open?
      if self.user != user && !applic
        if users.include?(user)
          actions.push('unwatch')
        else
          actions.push('watch')
        end
      end

      if open? || applic
        if !applic
          actions.push('apply')
        elsif applic.applied
          actions.push('applied')
        else
          actions.push('resume')
        end
      end
    end

    actions
  end

  ***REMOVED*** @return hash{ org => curated }
  def curations(user)
    curations = {}
    (user.admin? ? Org.all : user.orgs).each do |org|
      curations[org] = orgs.include?(org)
    end
    curations
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
  
  ***REMOVED*** The main search handler.
  ***REMOVED*** It should be the ONLY interface between search queries and jobs;
  ***REMOVED*** hopefully this will make the choice of search engine transparent
  ***REMOVED*** to our app.
  ***REMOVED***
  ***REMOVED*** By default, it finds an unlimited number of non-ended jobs.
  ***REMOVED*** You can also restrict by query, department, faculty, paid, credit,
  ***REMOVED*** and set a limit of max number of results.
  ***REMOVED***
  ***REMOVED*** @param query [Array, String] search terms
  ***REMOVED*** @param options [Hash]
  ***REMOVED*** @option options [Boolean] :included_ended if +false+, don't include jobs with end dates in the past
  ***REMOVED*** @option options [Integer] :department_id ID of department you want to search, or +0+ for all depts
  ***REMOVED*** @option options [Integer] :faculty ID of faculty member you want to search, or +0+ for all
  ***REMOVED*** @option options [Integer] :compensation a constant from {Compensation}. If {Compensation::Both},
  ***REMOVED***                             search for {Compensation::Paid paid} OR {Compensation::Credit credit}.
  ***REMOVED*** @option options [Integer] :limit max. number of results, or +0+ for no limit
  ***REMOVED*** @option options [Array] :tags tag strings to match (searches only tags and not body, title, etc.)
  ***REMOVED*** @option options [Array] :order custom sorting conditions, besides @relevance. Conditions concatenated left to right.
  ***REMOVED*** @option options [Boolean] :include_inactive if +true+, include inactive jobs
  ***REMOVED***
  def self.find_jobs(query=nil, options={})
    query = Job.sanitize_query(query)
    tables = Job.generate_relation_tables
    relation = Job.make_relation
    relation = Job.filter_by_query(query, relation, tables) if query
    relation = Job.filter_by_options(options, relation, tables) if options
    relation = relation.where(status: Job::Status::Open).sort_by(&:updated_at).reverse
    page = options[:page] || 1
    per_page = options[:per_page] || 16
    return relation.paginate(:page => page, :per_page => per_page)
  end
  
  ***REMOVED*** @return query for jobs joined with relevant tables
  def self.make_relation
    Job.all.includes(:faculties).includes(:department).includes(:tags)
       .includes(:proglangs).includes(:courses).includes(:categories)
  end
  
  ***REMOVED*** @return all results with at least one field that matches the search query
  def self.filter_by_query(query, relation, tables)
    relation.where(tables['jobs'][:title].matches(query)
                  .or(tables['jobs'][:desc].matches(query))
                  .or(tables['faculties'][:name].matches(query))
                  .or(tables['departments'][:name].matches(query))
                  .or(tables['proglangs'][:name].matches(query))
                  .or(tables['courses'][:name].matches(query))
                  .or(tables['categories'][:name].matches(query))
                  )
            .references(:proglangs).references(:courses).references(:categories)
  end
  
  ***REMOVED*** @return results filtered by the options
  def self.filter_by_options(options, relation, tables)
    relation = relation.where(tables['jobs'][:end_date].gt(Time.now).or(tables['jobs'][:end_date].eq(nil))) unless options[:include_ended]
    relation = relation.where(tables['departments'][:id].eq(options[:department_id])) if options[:department_id]
    relation = relation.where(tables['faculties'][:id].eq(options[:faculty_id])) if options[:faculty_id]

    ***REMOVED*** Search paid, credit
    if options[:compensation].present? and options[:compensation].to_i != Compensation::None
      compensations = []
      compensations << Compensation::Pay if (options[:compensation].to_i & Compensation::Pay) != 0
      compensations << Compensation::Credit if (options[:compensation].to_i & Compensation::Credit) != 0
      compensations << Compensation::Both unless compensations.empty?
      relation = relation.where(tables['jobs'][:compensation].in_any(compensations))
    end
    if options[:post_status].present?
      statuses = [options[:post_status]]
      relation = relation.where(tables['jobs'][:status].in_any(statuses))
    end

    relation = relation.where(tables['tags'][:name].matches(options[:tags])) if options[:tags].present?
    relation = relation.limit(options[:limit]) if options[:limit]
    order = options[:order] || "jobs.created_at DESC"
    relation = relation.order(order)
    return relation
  end
  
  ***REMOVED*** Build complex queries with arel tables
  def self.generate_relation_tables
    {
      'jobs' => Job.arel_table,
      'faculties' => Faculty.arel_table,
      'departments' => Department.arel_table,
      'proglangs' => Proglang.arel_table,
      'courses' => Course.arel_table,
      'categories' => Category.arel_table,
      'tags' => ActsAsTaggableOn::Tag.arel_table,
    }
  end
  
  ***REMOVED*** Processes user input to send to the database
  def self.sanitize_query(query)
    throw "Query must be a string" unless query.nil? || query.is_a?(String)
    query ||= ""
    query = query.gsub(/\\/, '\\\\\\\\').gsub(/%/, '\%').gsub(/_/, '\_')
    query = "%" + query + "%"
    return query
  end

  def self.query_url(options)
    params = {}
    params[:query]          = options[:query]               if options[:query]
    params[:department]     = options[:department_id]       if options[:department_id] and Department.exists?(options[:department_id])
    params[:compensation]   = options[:compensation]        if options[:compensation] and Job::Compensation::All.key(options[:compensation].to_i)
    url_for(:controller => 'jobs', :only_path=>true)+"?***REMOVED***{params.collect { |param, value| param+'='+value }.join('&')}"
  end
   
  def self.find_recently_added(n)
    Job.find_jobs :extra_conditions => { order: "created_at DESC", limit: n } 
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

  ***REMOVED*** Returns a list of relevant fields used to generate tags
  def field_list
    [ self.department.name,
      self.category_list_of_job,
      self.course_list_of_job,
      self.proglang_list_of_job,
      ('credit' if self.credit?),
      ('paid' if self.pay?)
    ].compact.reject(&:blank?)
  end

  ***REMOVED*** Reassigns it an activation code.
  ***REMOVED*** Used when creating a job or if, when updating the job, a new 
  ***REMOVED***   faculty sponsor is specified.
  def resend_email(send_email = false)
    self.activation_code = SecureRandom.random_number(10e6.to_i)

    ***REMOVED*** Save, skipping validations, so that we just change the activation code
    ***REMOVED*** and leave the rest alone! (Also so that we don't encounter weird bugs with
    ***REMOVED*** activating jobs whose end dates are in the past, etc.)
    self.save(:validate => false)

    if send_email
      ***REMOVED*** Send the email for activation.
      begin
        email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
        if !faculties.collect(&:email).select{|email| email === email_regex}.empty?
          JobMailer.activate_job_email(self).deliver
        end
      rescue => e
        Rails.logger.error "Failed to send activation mail for job***REMOVED******REMOVED***{self.id}: ***REMOVED***{e.inspect}"
        raise if Rails.development?
      end
    end
  end

  protected
  
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
