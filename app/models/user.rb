***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: users
***REMOVED***
***REMOVED***  id                  :integer          not null, primary key
***REMOVED***  name                :string(255)
***REMOVED***  login               :string(255)
***REMOVED***  email               :string(255)
***REMOVED***  persistence_token   :string(255)      not null
***REMOVED***  single_access_token :string(255)      not null
***REMOVED***  perishable_token    :string(255)      not null
***REMOVED***  login_count         :integer          default(0), not null
***REMOVED***  failed_login_count  :integer          default(0), not null
***REMOVED***  last_request_at     :datetime
***REMOVED***  current_login_at    :datetime
***REMOVED***  last_login_at       :datetime
***REMOVED***  current_login_ip    :string(255)
***REMOVED***  last_login_ip       :string(255)
***REMOVED***  user_type           :integer          default(0), not null
***REMOVED***  units               :integer
***REMOVED***  free_hours          :integer
***REMOVED***  research_blurb      :text
***REMOVED***  experience          :string(255)
***REMOVED***  summer              :boolean
***REMOVED***  url                 :string(255)
***REMOVED***  year                :integer
***REMOVED***

require 'digest/sha1'

class User < ActiveRecord::Base
  include AttribsHelper

  ***REMOVED*** Authlogic
  acts_as_authentic do |c|
    ***REMOVED***c.merge_validates_length_of_login_field_options :within => 1..100
    ***REMOVED*** so that logins can be 1 character in length even; 'login' is provided
    ***REMOVED*** by CAS so we don't want to artificially limit the values we get for it.

    c.validate_email_field = false
    c.validate_login_field = false
  end

  ***REMOVED*** Simplification of LDAP roles where earlier Types take priority
  ***REMOVED*** Default UI: Undergrad apply to research, others post research
  class Types
    Undergrad = 0
    Grad      = 1
    Faculty   = 2
    Staff     = 3
    Affiliate = 4
    Admin     = 5
    All       = [Undergrad, Grad, Faculty, Staff, Affiliate, Admin]
  end

  has_many :jobs,          :dependent => :nullify
  has_many :owns,          :dependent => :destroy
  has_many :owned_jobs,    :through => :owns, :source => :job

  has_many :applics
  has_many :applied_jobs,  :through => :applics, :source => :job

  has_many :watches,       :dependent => :destroy
  has_many :watched_jobs,  :through => :watches, :source => :job

  ***REMOVED*** TODO re-enable for Rails 4
  ***REMOVED*** has_one  :resume,        :class_name => 'Document', :conditions => {:document_type => Document::Types::Resume}, :dependent => :destroy
  ***REMOVED*** has_one  :transcript,    :class_name => 'Document', :conditions => {:document_type => Document::Types::Transcript}, :dependent => :destroy
  has_many :enrollments,   :dependent => :destroy
  has_many :courses,       :through => :enrollments
  has_many :interests,     :dependent => :destroy
  has_many :categories,    :through => :interests
  has_many :proficiencies, :dependent => :destroy
  has_many :proglangs,     :through => :proficiencies

  has_many :memberships
  has_many :orgs,          :through => :memberships
  has_one  :picture
  has_many :reviews

  ***REMOVED*** Name
  validates_presence_of     :name
  validates_presence_of     :email
  validates_length_of       :name,     :within => 0..100
  ***REMOVED*** ignore validation for now
  ***REMOVED*** validates_format_of       :name,     :with => /\A[A-Za-z\-_ \.']+\z/

  ***REMOVED*** Email
  ***REMOVED*** validates_presence_of     :email
  ***REMOVED*** validates_length_of       :email,    :within => 6..100 ***REMOVED***r@a.wk
  ***REMOVED*** validates_uniqueness_of   :email

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
  validates_inclusion_of    :user_type, :in => Types::All, :message => 'is invalid'

  ***REMOVED*** before_validation :handle_courses
  ***REMOVED*** before_validation :handle_categories
  ***REMOVED*** before_validation :handle_proglangs

  ***REMOVED*** attr_accessible :email, :units, :free_hours, :research_blurb, :experience, :summer, :url, :year
  attr_reader :course_names; attr_writer :course_names
  attr_reader :proglang_names; attr_writer :proglang_names
  attr_reader :category_names; attr_writer :category_names

  ***REMOVED*** Downcases email address
  def email=(value)
    write_attribute :email, (value && !value.empty? ? value.downcase : self.email)
  end

  ***REMOVED*** @return [UCB::LDAP::Person] for this User
  def ldap_person
    @person ||= UCB::LDAP::Person.find_by_uid(self.login) if self.login
  end

  ***REMOVED*** @return [String] Full name, as provided by LDAP
  def ldap_person_full_name
    "***REMOVED***{self.ldap_person.firstname} ***REMOVED***{self.ldap_person.lastname}".titleize
  end


  ***REMOVED*** Updates this User's Type based on LDAP information.
  ***REMOVED*** Raises an error if the user type can't be determined.
  ***REMOVED***
  ***REMOVED*** @param save [Hash] Also commit user type to the database (default +false+)
  ***REMOVED*** @return [Integer] Inferred user {Types Type}
  ***REMOVED***
  def update_user_type(save = false)
    person = self.ldap_person
    if person.nil?
      self.user_type = User::Types::Affiliate
    else
      self.user_type = case
                       when person.berkeleyEduStuUGCode == 'G'
                         User::Types::Grad
                       when person.student?
                         User::Types::Undergrad
                       when person.employee_expired?
                         User::Types::Affiliate
                       when person.employee_academic?
                         User::Types::Faculty
                       when person.employee?
                         User::Types::Staff
                       else
                         User::Types::Affiliate
                       end
    end
    self.update_attribute(:user_type, self.user_type) if save
    self.user_type
  end

  def admin?
    user_type == User::Types::Admin
  end
  ***REMOVED*** TODO this needs to be a db field.
  def apply?
    user_type == User::Types::Undergrad || user_type == User::Types::Admin
  end

  def post?
    user_type != User::Types::Undergrad || user_type == User::Types::Admin
  end

  ***REMOVED*** Readable user type
  def user_type_string
    case self.user_type
    when User::Types::Grad
      'Graduate Student'
    when User::Types::Undergrad
      'Undergraduate Student'
    when User::Types::Faculty
      'Faculty'
    when User::Types::Staff
      'Staff'
    when User::Types::Admin
      'Administrator'
    when User::Types::Affiliate
      'Affiliate'
    else
      'Unknown user type'
      logger.warn "Couldn't find user type string for user type ***REMOVED***{self.user_type}"
    end
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
      course_list[0..(course_list.length - 3)].upcase
    else
      course_list[0..(course_list.length - 2)].upcase
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
      category_list[0..(category_list.length - 3)].downcase
    else
      category_list[0..(category_list.length - 2)].downcase
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
      proglang_list[0..(proglang_list.length - 3)]
    else
      proglang_list[0..(proglang_list.length - 2)]
    end
  end

  ***REMOVED*** Makes more sense to handle these for each job
  ***REMOVED*** def received_jobs_list_of_user
  ***REMOVED***   jobs = []
  ***REMOVED***   self.applics.all.each do |w|
  ***REMOVED***     this_job = Job.find_by_id(w.job_id)
  ***REMOVED***     if this_job && w.status == "accepted" then
  ***REMOVED***       jobs << this_job
  ***REMOVED***     end
  ***REMOVED***   end
  ***REMOVED***   jobs
  ***REMOVED*** end

  ***REMOVED*** Parses the textbox list of courses from "CS162,CS61A,EE123"
  ***REMOVED*** etc. to an enumerable object courses
  def handle_courses(course_names)
    return if !self.apply? || course_names.nil?
    self.courses = []  ***REMOVED*** eliminates any previous enrollments so as to avoid duplicates
    course_array = []
    course_array = course_names.split(',').uniq if course_names
    course_array.each do |item|
      self.courses << Course.find_or_create_by(name: item.upcase.strip)
    end
  end

  ***REMOVED*** Parses the textbox list of categories from "signal processing,robotics"
  ***REMOVED*** etc. to an enumerable object categories
  def handle_categories(category_names)
    return if !self.apply? || category_names
    self.categories = []  ***REMOVED*** eliminates any previous interests so as to avoid duplicates
    category_array = []
    category_array = category_names.split(',').uniq if category_names
    category_array.each do |cat|
      self.categories << Category.find_or_create_by(name: cat.downcase.strip)
    end
  end

  ***REMOVED*** Parses the textbox list of proglangs from "c++,python"
  ***REMOVED*** etc. to an enumerable object proglangs
  def handle_proglangs(proglang_names)
    return if !self.apply? || proglang_names.nil?
    self.proglangs = []  ***REMOVED*** eliminates any previous proficiencies so as to avoid duplicates
    proglang_array = []
    proglang_array = proglang_names.split(',').uniq if proglang_names
    proglang_array.each do |pl|
      self.proglangs << Proglang.find_or_create_by(name: pl.upcase.strip)
    end
  end

  ***REMOVED*** @return [Boolean] true if the user has just been activated.
  ***REMOVED*** @deprecated
  def recently_activated?
    false
  end

  ***REMOVED*** @return [User] the user corresponding to given login
  ***REMOVED*** @deprecated
  def self.authenticate_by_login(loggin)
    ***REMOVED*** Return user corresponding to login, or nil if there isn't one
    User.find_by_login(loggin)
  end

  ***REMOVED*** @deprecated
  def is_faculty?
    user_type == User::Types::Faculty
  end
  protected

    ***REMOVED*** Dynamically assign the value of :email, based on whether this user
    ***REMOVED*** is marked as faculty or not. This should occur as a before_validation
    ***REMOVED*** since we want to save a value for :email, not :faculty_email or :student_email.
    ***REMOVED*** @deprecated
    def handle_email
      self.email = (self.is_faculty? ? Faculty.find_by_name(self.faculty_name).email : self.student_email)
    end

    ***REMOVED*** Dynamically assign the value of :name, based on whether this user
    ***REMOVED*** is marked as faculty or not. This should occur as a before_validation
    ***REMOVED*** since we want to save a value for :name, not :faculty_name or :student_name.
    ***REMOVED*** @deprecated
    def handle_name
      if self.name.nil? || self.name == ""
        self.name = is_faculty? ? faculty_name : student_name
      end
    end
end
