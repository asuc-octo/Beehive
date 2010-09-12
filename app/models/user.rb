require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  
  has_many :jobs
  has_many :reviews
  has_one :picture
  
  has_many :reviews
  has_many :watches
  has_many :enrollments
  has_many :courses, :through => :enrollments
  has_many :interests
  has_many :categories, :through => :interests
  has_many :proficiencies
  has_many :proglangs, :through => :proficiencies
  

  ***REMOVED***validates_presence_of     :login
  ***REMOVED***validates_length_of       :login,    :within => 3..40
  ***REMOVED***validates_uniqueness_of   :login
  ***REMOVED***validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message
  
  validates_presence_of :name
  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :within => 0..100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 ***REMOVED***r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
  
  ***REMOVED*** Check that the email address is @*.berkeley.edu or @*.lbl.gov
  validates_format_of		:email,	   :with => /^[^@]+@(?:.+\.)?(?:(?:berkeley\.edu)|(?:lbl\.gov))$/i, :message => "The specified email is not a Berkeley or LBL address."

  before_create :make_activation_code 
  
  ***REMOVED*** Before carrying out validations (i.e., before actually creating the user object), assign the proper 
  ***REMOVED*** email address to the user (depending on whether the user is a student or gsi or a faculty) 
  ***REMOVED*** and handle the courses for the user.
  before_validation :handle_email
  before_validation :handle_name
  before_validation :handle_courses
  before_validation :handle_categories
  before_validation :handle_proglangs
  
  ***REMOVED*** HACK HACK HACK -- how to do attr_accessible from here?
  ***REMOVED*** prevents a user from submitting a crafted form that bypasses activation
  ***REMOVED*** anything else you want your user to change should be added here.
  attr_accessible :email, :name, :password, :password_confirmation, :faculty_email, :student_email, :is_faculty, :course_names, 
	:category_names, :student_name, :faculty_name, :proglang_names
  attr_reader :faculty_email; attr_writer :faculty_email  
  attr_reader :student_email; attr_writer :student_email
  attr_reader :course_names; attr_writer :course_names
  attr_reader :proglang_names; attr_writer :proglang_names
  attr_reader :category_names; attr_writer :category_names
  attr_reader :student_name; attr_writer :student_name
  attr_reader :faculty_name; attr_writer :faculty_name
  
  ***REMOVED*** Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  ***REMOVED*** Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def active?
    ***REMOVED*** the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  ***REMOVED*** Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  ***REMOVED***
  ***REMOVED*** uff.  this is really an authorization, not authentication routine.  
  ***REMOVED*** We really need a Dispatch Chain here or something.
  ***REMOVED*** This will also let us return a human error message.
  ***REMOVED***
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email] ***REMOVED*** need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  ***REMOVED***def login=(value)
  ***REMOVED***  write_attribute :login, (value ? value.downcase : nil)
  ***REMOVED***end

  def email=(value)
    write_attribute :email, (value && !value.empty? ? value.downcase : self.email)
  end
  
  
  ***REMOVED*** Returns a string containing the course names taken by user @user
  ***REMOVED*** e.g. "CS162,CS61A"
  def course_list_of_user
  	course_list = ''
  	courses.each do |course|
  		course_list << course.name + ','
  	end
  	course_list[0..(course_list.length - 2)].upcase
  end

  ***REMOVED*** Returns a string containing the category names taken by user @user
  ***REMOVED*** e.g. "signal processing,robotics,algorithms"
  def category_list_of_user
  	category_list = ''
  	categories.each do |cat|
  		category_list << cat.name + ','
  	end
  	category_list[0..(category_list.length - 2)].downcase
  end
  
  ***REMOVED*** Returns a string containing the proglang names taken by user @user
  ***REMOVED*** e.g. "java,c++,ruby"
  def proglang_list_of_user
  	proglang_list = ''
  	proglangs.each do |pl|
  		proglang_list << pl.name + ','
  	end
  	proglang_list[0..(proglang_list.length - 2)].downcase
  end
  
  ***REMOVED*** Returns an array of this user's watched jobs
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
    ***REMOVED***@watched_jobs = current_user.watches.map{|w| w.job }
  end
  
  protected
    

    def make_activation_code
  
      self.activation_code = self.class.make_token
    end

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
		self.proglangs = []  ***REMOVED*** eliminates any previous proficiencies so as to avoid duplicates
		proglang_array = []
		proglang_array = proglang_names.split(',').uniq if ! proglang_names.nil?
		proglang_array.each do |pl|
			self.proglangs << Proglang.find_or_create_by_name(pl.downcase.strip)
		end
	end	

	
end
