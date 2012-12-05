require 'digest/sha1'

class User < ActiveRecord::Base

  ***REMOVED*** === List of columns ===
  ***REMOVED***   id                  : integer 
  ***REMOVED***   name                : string 
  ***REMOVED***   login               : string 
  ***REMOVED***   email               : string 
  ***REMOVED***   persistence_token   : string 
  ***REMOVED***   single_access_token : string 
  ***REMOVED***   perishable_token    : string 
  ***REMOVED***   login_count         : integer 
  ***REMOVED***   failed_login_count  : integer 
  ***REMOVED***   last_request_at     : datetime 
  ***REMOVED***   current_login_at    : datetime 
  ***REMOVED***   last_login_at       : datetime 
  ***REMOVED***   current_login_ip    : string 
  ***REMOVED***   last_login_ip       : string 
  ***REMOVED***   user_type           : integer 
  ***REMOVED***   units               : integer 
  ***REMOVED***   free_hours          : integer 
  ***REMOVED***   research_blurb      : text 
  ***REMOVED***   experience          : string 
  ***REMOVED***   summer              : boolean 
  ***REMOVED***   url                 : string 
  ***REMOVED***   year                : integer 
  ***REMOVED*** =======================

  include AttribsHelper

  ***REMOVED*** Authlogic
  acts_as_authentic do |c|
    ***REMOVED***c.merge_validates_length_of_login_field_options :within => 1..100
    ***REMOVED*** so that logins can be 1 character in length even; 'login' is provided
    ***REMOVED*** by CAS so we don't want to artificially limit the values we get for it.

    ***REMOVED***c.validate_email_field = true
    c.validate_login_field = false
  end

  class Types
      Undergrad = 0
      Grad      = 1
      Faculty   = 2
      Admin     = 3
      All       = [Undergrad, Grad, Faculty, Admin]
  end

  has_many :jobs,        :dependent => :nullify
  has_many :reviews
  has_one  :picture
  has_one  :resume,      :class_name => 'Document', :conditions => {:document_type => Document::Types::Resume}, :dependent => :destroy
  has_one  :transcript,  :class_name => 'Document', :conditions => {:document_type => Document::Types::Transcript}, :dependent => :destroy
  has_many :reviews
  has_many :owns
  has_many :applics
  has_many :applied_jobs,  :through => :applics, :source => :job
  has_many :owned_jobs,    :through => :owns, :source => :job
  has_many :watches,       :dependent => :destroy
  has_many :enrollments,   :dependent => :destroy
  has_many :courses,       :through => :enrollments
  has_many :interests,     :dependent => :destroy
  has_many :categories,    :through => :interests
  has_many :proficiencies, :dependent => :destroy
  has_many :proglangs,     :through => :proficiencies

  ***REMOVED*** Name
  validates_presence_of     :name
  validates_length_of       :name,     :within => 0..100
  validates_format_of       :name,     :with => /\A[A-Za-z\-_ \.']+\z/

  ***REMOVED*** Email
  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 ***REMOVED***r@a.wk
***REMOVED***validates_uniqueness_of   :email

  ***REMOVED*** Login
  validates_uniqueness_of   :login

  ***REMOVED*** Misc info
  validates_numericality_of :units,          :allow_nil => true
  validates_numericality_of :free_hours,     :allow_nil => true
  validates_length_of       :experience,     :maximum => 255
  validates_length_of       :research_blurb, :maximum => 300
  validates_length_of       :url,            :maximum => 255
  validates_numericality_of :year,           :allow_nil => true
  validates_inclusion_of    :year,           :in => (1..4), :allow_nil => true

  ***REMOVED*** Check that user type is valid
  validates_inclusion_of    :user_type, :in => Types::All, :message => "is invalid"

  before_validation :handle_courses
  before_validation :handle_categories
  before_validation :handle_proglangs

  attr_accessible :email, :units, :free_hours, :research_blurb, :experience, :summer, :url, :year

  attr_reader :course_names; attr_writer :course_names
  attr_reader :proglang_names; attr_writer :proglang_names
  attr_reader :category_names; attr_writer :category_names

  ***REMOVED*** @return [Boolean] true if the user has just been activated.
  ***REMOVED*** @deprecated
  def recently_activated?
    false 
  end

  ***REMOVED*** @return [User] the user corresponding to given login
  def self.authenticate_by_login(loggin)
    ***REMOVED*** Return user corresponding to login, or nil if there isn't one
    User.find_by_login(loggin)
  end

  ***REMOVED*** Downcases email address
  def email=(value)
    write_attribute :email, (value && !value.empty? ? value.downcase : self.email)
  end
  
  
  ***REMOVED*** @param add_spaces [Boolean] use ', ' as separator instead of ','
  ***REMOVED*** @return [String] the 'required course' names taken by this User, e.g. "CS61A,CS61B"
  def course_list_of_user(add_spaces = false)
  	course_list = ''
  	courses.each do |c|
  		course_list << c.name + ','
  		course_list << ' ' if add_spaces
  	end
  	
  	if add_spaces
  	  return course_list[0..(course_list.length - 3)].upcase
	  else
    	return course_list[0..(course_list.length - 2)].upcase
  	end
  end

  ***REMOVED*** @param add_spaces [Boolean] use ', ' as separator instead of ','
  ***REMOVED*** @return [String] the category names taken by this User, e.g. "robotics,signal processing"
  def category_list_of_user(add_spaces = false)
  	category_list = ''
  	categories.each do |cat|
  		category_list << cat.name + ','
  		category_list << ' ' if add_spaces
  	end
  	
  	if add_spaces
  	  return category_list[0..(category_list.length - 3)].downcase
	  else
    	return category_list[0..(category_list.length - 2)].downcase
  	end
  end
  
  ***REMOVED*** @return [String] the 'desired proglang' names taken by this User, e.g. "java,scheme,c++"
  def proglang_list_of_user(add_spaces = false)
  	proglang_list = ''
  	proglangs.each do |pl|
  		proglang_list << pl.name.capitalize + ','
   		proglang_list << ' ' if add_spaces
  	end
  	
  	if add_spaces
  	  return proglang_list[0..(proglang_list.length - 3)]
	  else
    	return proglang_list[0..(proglang_list.length - 2)]
  	end
  end
  
  ***REMOVED*** @return [Array<Job>] this user's watched jobs
  def watched_jobs_list_of_user
    jobs = []
    self.watches.all.each do |w|
        this_job = Job.find_by_id(w.job_id)
        if this_job then
            jobs << this_job
        else
            w.destroy
        end
    end
    jobs
    ***REMOVED***@watched_jobs = @current_user.watches.map{|w| w.job }
  end
  
  
  ***REMOVED*** is_faculty for backward compatibility
  def is_faculty
    self.user_type == User::Types::Faculty
  end
  
  def can_post?
    [User::Types::Grad, User::Types::Faculty, User::Types::Admin].include? self.user_type
  end


  ***REMOVED*** @return [UCB::LDAP::Person] for this User
  def ldap_person
    @person ||= UCB::LDAP::Person.find_by_uid(self.login) if self.login
  end

  ***REMOVED*** @return [String] Full name, as provided by LDAP
  def ldap_person_full_name
    "***REMOVED***{self.ldap_person.firstname} ***REMOVED***{self.ldap_person.lastname}".titleize
  end


  ***REMOVED*** Updates this User's role, based on the
  ***REMOVED*** LDAP information. Raises an error if the user type can't be determined.
  ***REMOVED***
  ***REMOVED*** @param options [Hash]
  ***REMOVED*** @option options [Boolean] :save Also commit user type to the database (default +false+)
  ***REMOVED*** @option options [Boolean] :update Same as +:save+
  ***REMOVED*** @return [Integer] Inferred user {Types Type}
  ***REMOVED***
  def update_user_type(options={})
    unless options[:stub].blank?   ***REMOVED*** stub type
      options[:stub] = User::Types::Undergrad unless User::Types::All.include?(options[:stub].to_i)
      self.user_type = options[:stub].to_i
    else  ***REMOVED*** update via LDAP
      person = self.ldap_person
      case   ***REMOVED*** Determine role
        ***REMOVED*** Faculty
        when (person.employee_academic? and not person.employee_expired? and not ['G','U'].include?(person.berkeleyEduStuUGCode))
          self.user_type = User::Types::Faculty

        ***REMOVED*** Student
        when (person.student? and person.student_registered?)
          case person.berkeleyEduStuUGCode
            when 'G'
              self.user_type = User::Types::Grad
            when 'U' 
              self.user_type = User::Types::Undergrad
            else
              logger.error "User.update_user_type: Couldn't determine student type for login ***REMOVED***{self.login}"
              raise StandardError, "berkeleyEduStuUGCode not accessible. Have you authenticated with LDAP?"
          end ***REMOVED*** under/grad
        else
          logger.error "User.update_user_type: Couldn't determine user type for login ***REMOVED***{self.login}, defaulting to Undergrad"
          ***REMOVED***raise StandardError, "couldn't determine user type for login ***REMOVED***{self.login}"
          self.user_type = User::Types::Undergrad
        end ***REMOVED*** employee/student
    end ***REMOVED*** stub

    self.update_attribute(:user_type, self.user_type) if options[:save] || options[:update]
    self.user_type
  end

  def is_faculty?
    user_type == User::Types::Faculty
  end
  def is_grad?
    user_type == User::Types::Grad
  end
  def is_undergrad?
    user_type == User::Types::Undergrad
  end

  ***REMOVED*** @return [Boolean] is the user an {Types::Admin Admin}?
  def admin?
    user_type == User::Types::Admin
  end

  ***REMOVED*** User type, as a string
  ***REMOVED*** TODO: there's probably a better way to do this programmatically
  def user_type_string(options={})
    options[:long] ||= false
    s = ''

    case self.user_type
    when User::Types::Faculty
      s = 'Faculty'
      s += ' member' if options[:long]
    when User::Types::Grad
      s = 'Grad student/postdoc'
    when User::Types::Undergrad
      s = 'Undergrad'
      s += 'uate' if options[:long]
    when User::Types::Admin
      s = 'Administrator'
    else
      s = '(undefined)'
      logger.warn "Couldn't find user type string for user type ***REMOVED***{self.user_type}"
    end
    s
  end
  
  protected
    
    ***REMOVED*** Dynamically assign the value of :email, based on whether this user
    ***REMOVED*** is marked as faculty or not. This should occur as a before_validation
    ***REMOVED*** since we want to save a value for :email, not :faculty_email or :student_email.
    def handle_email
      self.email = (self.is_faculty ? Faculty.find_by_name(self.faculty_name).email : self.student_email)
    end
    
    ***REMOVED*** Dynamically assign the value of :name, based on whether this user
    ***REMOVED*** is marked as faculty or not. This should occur as a before_validation
    ***REMOVED*** since we want to save a value for :name, not :faculty_name or :student_name.
    def handle_name
      if self.name.nil? || self.name == ""
              self.name = is_faculty ? faculty_name : student_name
      end
    end

    ***REMOVED*** Parses the textbox list of courses from "CS162,CS61A,EE123"
    ***REMOVED*** etc. to an enumerable object courses
    def handle_courses
      return if self.is_faculty?
      self.courses = []  ***REMOVED*** eliminates any previous enrollments so as to avoid duplicates
      course_array = []
      course_array = course_names.split(',').uniq if ! course_names.nil?
      course_array.each do |item|
              self.courses << Course.find_or_create_by_name(item.upcase.strip)
      end
    end
    
    ***REMOVED*** Parses the textbox list of categories from "signal processing,robotics"
    ***REMOVED*** etc. to an enumerable object categories
    def handle_categories
      return if self.is_faculty?
      self.categories = []  ***REMOVED*** eliminates any previous interests so as to avoid duplicates
      category_array = []
      category_array = category_names.split(',').uniq if ! category_names.nil?
      category_array.each do |cat|
              self.categories << Category.find_or_create_by_name(cat.downcase.strip)
      end
    end
    
    ***REMOVED*** Parses the textbox list of proglangs from "c++,python"
    ***REMOVED*** etc. to an enumerable object proglangs
    def handle_proglangs
      return if self.is_faculty?
      self.proglangs = []  ***REMOVED*** eliminates any previous proficiencies so as to avoid duplicates
      proglang_array = []
      proglang_array = proglang_names.split(',').uniq if ! proglang_names.nil?
      proglang_array.each do |pl|
              self.proglangs << Proglang.find_or_create_by_name(pl.downcase.strip)
      end
    end	
end
