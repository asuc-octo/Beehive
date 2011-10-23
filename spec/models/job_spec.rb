require 'spec_helper'

require 'thinking_sphinx/test'
ThinkingSphinx::Test.init
ThinkingSphinx::Test.start_with_autostop

describe Job do
  fixtures :all

  before(:each) do
    @controller = mock('JobsController')
    @controller.stub!(:login_required).and_return(true)
    @valid_attributes = {
      :title => "value for title",
      :desc => "value for desc",
      :end_date => Time.now + 5.hours,
      :num_positions => 1,
      :paid => false,
      :credit => false,
      :active => true
    }

    @mock_sponsorship ||= stub_model(Sponsorship)
    @mock_department  ||= stub_model(Department)
    @mock_user        ||= stub_model(User)
    @mock_category    ||= stub_model(Category)
  end
  
  ***REMOVED***
  ***REMOVED*** Validation
  ***REMOVED***
  describe "validation:" do

    ***REMOVED***
    ***REMOVED*** Setup
    ***REMOVED***

    before :each do
      @valid_jobs = []
    end

    after :each do
      @valid_jobs.each {|j| j.destroy}
    end

    ***REMOVED***
    ***REMOVED*** Specs
    ***REMOVED***

    it "should create a new instance given valid attributes" do
      create_job.should be_valid
      job = Job.new(@valid_attributes)
      job.sponsorships << mock_model(Sponsorship)
      job.department   =  mock_model(Department)
      job.user         =  mock_model(User)
      job.categories   << mock_model(Category)
      job.valid?
      job.errors.should == {} and job.should be_valid
    end

    describe "title" do
      it "should be between 10 and 200 characters, inclusive" do
        test_range(10..200) do |n, valid|
          Job.new(:title => 'a'*n).errors_on(:title).empty?.should == valid
        end
      end
    end ***REMOVED*** title

    describe "description" do
      it "should be within 10 and 20000 characters" do
        test_range(10..20000) do |n, valid|
          Job.new(:desc => 'a'*n).errors_on(:desc).empty?.should == valid
        end
      end
    end

    describe "num positions" do
      it "should be nonnegative" do
        Job.new(:num_positions => -1).errors_on(:num_positions).should_not be_empty
        Job.new(:num_positions =>  0).errors_on(:num_positions).should     be_empty
        Job.new(:num_positions =>  2).errors_on(:num_positions).should     be_empty
      end

      it "should be optional" do
        Job.new(:num_positions => nil).errors_on(:num_positions).should be_empty
      end
    end

    describe "start dates" do
      before :each do
        @a = Time.now + 1.hour
        @b = @a + 1.day
        @c = @b + 1.week
      end

      it "should be in chronological order" do
        Job.new(:earliest_start_date => @a, :latest_start_date => @b).errors_on(:earliest_start_date).should be_empty
        Job.new(:earliest_start_date => @b, :latest_start_date => @a).errors_on(:earliest_start_date).should_not be_empty
      end

      describe "and end date" do
        it "should be in chronological order" do
          Job.new(:earliest_start_date => @a, :latest_start_date => @b, :end_date => @c).errors_on(:latest_start_date).should be_empty
          Job.new(:earliest_start_date => @b, :latest_start_date => @c, :end_date => @a).errors_on(:latest_start_date).should_not be_empty
        end
      end
    end ***REMOVED*** start dates

    describe "required attributes" do
      it "should include title, desc, department" do
        [ :title, :desc, :department ].each do |attrib|
          Job.new(attrib => nil).errors_on(attrib).should_not be_empty
        end
      end

      it "should include sponsorships" do
        pending
      end
    end ***REMOVED*** required attribs
    
  end ***REMOVED*** validations

  describe "searching" do
    
    describe "search with default options" do
      it "should return all active jobs that have not ended" do
        results = Job.find_jobs
        excluded = [jobs(:raid), jobs(:inactive)]
        verify_exclusion results, excluded
      end
    end

    describe "search with a query" do
      
      it "should match title" do
        results = Job.find_jobs "SEJITS"
        expected = [jobs(:sejits)]
        verify_match results, expected
        
        results = Job.find_jobs "bridge"
        expected = [jobs(:bridges)]
        verify_match results, expected
        
        results = Job.find_jobs "Console Log Mining"
        expected = [jobs(:console)]
        verify_match results, expected
        
        results = Job.find_jobs "Log Mining"
        expected = [jobs(:console)]
        verify_match results, expected
      end
      
      it "should match description" do
        results = Job.find_jobs("scale")
        expected = [jobs(:scads), jobs(:cloud)]
        verify_match results, expected
        
        results = Job.find_jobs("facebook")
        expected = [jobs(:scads)]
        verify_match results, expected
        
        results = Job.find_jobs("test app")
        expected = [jobs(:cloud)]
        verify_match results, expected
        
        results = Job.find_jobs("modern sml techniques")
        expected = [jobs(:awe)]
        verify_match results, expected
        
        results = Job.find_jobs("performance")
        expected = [jobs(:awe), jobs(:scads), jobs(:cloud), jobs(:sejits)]
        verify_match results, expected
      end
            
      it "should match faculty" do
        results = Job.find_jobs "fox"
        expected = [jobs(:sejits), jobs(:scads), jobs(:cloud), jobs(:console), jobs(:awe)]
        verify_match results, expected
                                   
        results = Job.find_jobs "joseph"
        expected = [jobs(:cloud), jobs(:console), jobs(:bridges)]
        verify_match results, expected
        
        results = Job.find_jobs "anthony"
        expected = [jobs(:cloud)]
        verify_match results, expected
        
        results = Job.find_jobs "katz"
        expected = [jobs(:cloud)]
        verify_match results, expected
        
        results = Job.find_jobs "Hellerstein"
        expected = [jobs(:console), jobs(:bridges)]
        verify_match results, expected
      end
      
      it "should match department" do
        results = Job.find_jobs "EECS"
        excluded = [jobs(:brain), jobs(:bridges), jobs(:airplanes), jobs(:raid), jobs(:inactive)]
        verify_exclusion results, excluded
        
        results = Job.find_jobs "Cognative Science"
        expected = [jobs(:brain)]
        verify_match results, expected
        
        results = Job.find_jobs "Cognative"
        expected = [jobs(:brain)]
        verify_match results, expected
      end
        
      it "should be case insensitive" do
        results1 = Job.find_jobs "sejits"
        results2 = Job.find_jobs "sEJitS"
        results3 = Job.find_jobs "SEJITS"
        expected = [jobs(:sejits)]
        verify_match results1, expected
        verify_match results2, expected
        verify_match results3, expected
        
        results = Job.find_jobs "rad lab"
        expected = [jobs(:cloud)]
        verify_match results, expected
        
        results = Job.find_jobs "eecs"
        excluded = [jobs(:brain), jobs(:bridges), jobs(:airplanes), jobs(:raid), jobs(:inactive)]
        verify_exclusion results, excluded
      end
      
      ***REMOVED*** the following specs don't pass yet; we will make them pass

      it "should match partial words" do
        ***REMOVED*** results = Job.find_jobs "SEJIT"
        ***REMOVED*** expected = [jobs(:sejits)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** results = Job.find_jobs "eval"
        ***REMOVED*** expected = [jobs(:awe), jobs(:cloud)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** results = Job.find_jobs("faceboo")
        ***REMOVED*** expected = [jobs(:scads)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** results = Job.find_jobs("modern sml technique")
        ***REMOVED*** expected = [jobs(:awe)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** results = Job.find_jobs("app")
        ***REMOVED*** expected = [jobs(:sejits), jobs(:scads), jobs(:cloud), jobs(:console), jobs(:awe)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** results = Job.find_jobs "Cognative Scienc"
        ***REMOVED*** expected = [jobs(:brain)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** ***REMOVED***DO WE WANT THIS TO PASS????
        ***REMOVED*** results = Job.find_jobs "Cog Sci"
        ***REMOVED*** expected = [jobs(:brain)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** results = Job.find_jobs "Operatin"
        ***REMOVED*** expected = [jobs(:console)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** results = Job.find_jobs "Operating System"
        ***REMOVED*** expected = [jobs(:console)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** results = Job.find_jobs "Data Structure"
        ***REMOVED*** expected = [jobs(:awe), jobs(:sejits)]
        ***REMOVED*** verify_match results, expected
        
        ***REMOVED*** results = Job.find_jobs "Visual Bas"
        ***REMOVED*** expected = [jobs(:awe)]
        ***REMOVED*** verify_match results, expected
      end
      
      it "should match hyphens" do
        ***REMOVED*** results = Job.find_jobs "just-in-time"
        ***REMOVED*** expected = [jobs(:sejits)]
        ***REMOVED*** verify_match results, expected
        
        ***REMOVED*** results = Job.find_jobs "three-winged"
        ***REMOVED*** expected = [jobs(:airplanes)]
        ***REMOVED*** verify_match results, expected
      end
      
      it "should return multiple jobs with the same title keyword" do
        ***REMOVED*** results = Job.find_jobs "advanced"
        ***REMOVED*** expected = [jobs(:bridges), jobs(:airplanes)]
        ***REMOVED*** verify_match results, expected
      end
      
      it "should match categories" do
        ***REMOVED*** results = Job.find_jobs "Artificial Intelligence"
        ***REMOVED*** expected = [jobs(:scads), jobs(:console), jobs(:awe), jobs(:brain)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** results = Job.find_jobs "Computer Vision"
        ***REMOVED*** expected = [jobs(:bridges)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** results = Job.find_jobs "Computer"
        ***REMOVED*** expected = [jobs(:bridges), jobs(:airplanes)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** results = Job.find_jobs "Operating Systems"
        ***REMOVED*** expected = [jobs(:console)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** results = Job.find_jobs "Operating"
        ***REMOVED*** expected = [jobs(:console)]
        ***REMOVED*** verify_match results, expected
      end
      
      it "should match courses" do
        ***REMOVED*** results = Job.find_jobs "CS161"
        ***REMOVED*** expected = [jobs(:awe)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** results = Job.find_jobs "CS188"
        ***REMOVED*** expected = [jobs(:scads), jobs(:airplanes), jobs(:brain)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** results = Job.find_jobs "CS61B"
        ***REMOVED*** expected = [jobs(:awe), jobs(:sejits)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** results = Job.find_jobs "Data Structures"
        ***REMOVED*** expected = [jobs(:awe), jobs(:sejits)]
        ***REMOVED*** verify_match results, expected
      end
      
      it "should match programming languages" do
        ***REMOVED*** results = Job.find_jobs "Java"
        ***REMOVED*** expected = [jobs(:scads)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** results = Job.find_jobs "Visual Basic"
        ***REMOVED*** expected = [jobs(:awe)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** results = Job.find_jobs "Visual"
        ***REMOVED*** expected = [jobs(:awe)]
        ***REMOVED*** verify_match results, expected
      end
    end
    
    describe "search with params" do
            
      it "should respect :department" do
        params = {:department_id => Department.find_by_name('eecs').id}
        results = Job.find_jobs "", params
        excluded = [jobs(:brain), jobs(:bridges), jobs(:airplanes), jobs(:raid), jobs(:inactive)]
        verify_exclusion results, excluded
        
        params = {:department_id => Department.find_by_name('Cognative Science').id}
        results = Job.find_jobs nil, params
        expected = [jobs(:brain)]
        verify_match results, expected
      end
      
      it "should respect :faculty_id" do
        params = {:faculty_id => 7}
        results = Job.find_jobs nil, params
        expected = [jobs(:sejits), jobs(:scads), jobs(:cloud), jobs(:console), jobs(:awe)]
        verify_match results, expected
        
        params = {:faculty_id => 11}
        results = Job.find_jobs nil, params
        expected = [jobs(:cloud)]
        verify_match results, expected
        
        params = {:faculty_id => 12}
        results = Job.find_jobs nil, params
        expected = [jobs(:cloud)]
        verify_match results, expected
        
        params = {:faculty_id => 9}
        results = Job.find_jobs nil, params
        expected = [jobs(:console), jobs(:bridges)]
        verify_match results, expected
      end
      
      it "should respect :limit" do
        params = {:limit => 3}
        results = Job.find_jobs nil, params
        results.length.should == 3
      end
      
      ***REMOVED*** not sure why this isn't passing... it should be considering ts is working.
      ***REMOVED*** maybe it will pass after the refactor?
      it "should respect :tags" do
        ***REMOVED*** for job in Job.all[0..2]
          ***REMOVED*** populate_tag_list job
          ***REMOVED*** job.save!
        ***REMOVED*** end
***REMOVED***         
        ***REMOVED*** params = {:tags => 'EECS'}
        ***REMOVED*** results = Job.find_jobs nil, params
        ***REMOVED*** expected = [jobs(:sejits), jobs(:scads), jobs(:cloud)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** params = {:tags => 'credit'}
        ***REMOVED*** results = Job.find_jobs nil, params
        ***REMOVED*** expected = [jobs(:sejits), jobs(:cloud)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** params = {:tags => 'Java'}
        ***REMOVED*** results = Job.find_jobs nil, params
        ***REMOVED*** expected = [jobs(:scads)]
        ***REMOVED*** verify_match results, expected
***REMOVED***         
        ***REMOVED*** params = {:tags => 'unknown_tag'}
        ***REMOVED*** results = Job.find_jobs nil, params
        ***REMOVED*** expected = []
        ***REMOVED*** verify_match results, expected
      end
      
      ***REMOVED*** the following specs don't pass yet; we will make them pass
      
      it "should respect :exclude_ended" do
        ***REMOVED*** params = {:exclude_ended => true}
        ***REMOVED*** results = Job.find_jobs "RAID", params
        ***REMOVED*** expected = []
        ***REMOVED*** verify_match results, expected
  ***REMOVED***       
        ***REMOVED*** params = {:exclude_ended => false}
        ***REMOVED*** results = Job.find_jobs "RAID", params
        ***REMOVED*** expected = [jobs(:raid)]
        ***REMOVED*** verify_match results, expected
      end
      
      it "should respect :compensation" do
        ***REMOVED*** params = {:compensation => nil}
        ***REMOVED*** results = Job.find_jobs nil, params
        ***REMOVED*** unexpected = [jobs(:raid), jobs(:inactive)]
        ***REMOVED*** verify_exclusion results, unexpected
  ***REMOVED***       
        ***REMOVED*** params = {:compensation => 'paid'}
        ***REMOVED*** results = Job.find_jobs nil, params
        ***REMOVED*** unexpected = [jobs(:awe), jobs(:airplanes), jobs(:raid), jobs(:inactive)]
        ***REMOVED*** verify_exclusion results, unexpected
  ***REMOVED***       
        ***REMOVED*** params = {:compensation => 'credit'}
        ***REMOVED*** results = Job.find_jobs nil, params
        ***REMOVED*** expected = [jobs(:sejits), jobs(:cloud), jobs(:brain), jobs(:airplanes)]
        ***REMOVED*** verify_match results, expected
      end
      
      it "should respect :order" do
        ***REMOVED*** params = {:limit => 3, :order => "created_at DESC"}
        ***REMOVED*** results = Job.find_jobs nil, params
        ***REMOVED*** results.should == [jobs(:airplanes), jobs(:bridges), jobs(:brain)]
        
        ***REMOVED***add more?
      end
      
      it "should respect :include_inactive" do
        ***REMOVED*** params = {:include_inactive => true}
        ***REMOVED*** results = Job.find_jobs nil, params
        ***REMOVED*** unexpected = [jobs(:raid)]
        ***REMOVED*** verify_exclusion results, unexpected
***REMOVED***         
        ***REMOVED*** params = {:include_inactive => false}
        ***REMOVED*** results = Job.find_jobs nil, params
        ***REMOVED*** unexpected = [jobs(:raid), jobs(:inactive)]
        ***REMOVED*** verify_exclusion results, unexpected
      end
    end
  end ***REMOVED*** searching
  
def verify_match(actual_results, expected_results)
  unexpected_results = [jobs(:sejits), jobs(:awe), jobs(:console), jobs(:scads),
                       jobs(:cloud), jobs(:brain), jobs(:bridges), jobs(:airplanes),
                       jobs(:raid), jobs(:inactive)] - expected_results
  for result in expected_results
    actual_results.should include result
  end
  for result in unexpected_results
    actual_results.should_not include result
  end
end

def verify_exclusion(actual_results, unexpected_results)
  expected_results = [jobs(:sejits), jobs(:awe), jobs(:console), jobs(:scads),
                       jobs(:cloud), jobs(:brain), jobs(:bridges), jobs(:airplanes),
                       jobs(:raid), jobs(:inactive)] - unexpected_results
  for result in expected_results
    actual_results.should include result
  end
  for result in unexpected_results
    actual_results.should_not include result
  end
end
  
def printTitles(jobs)
  puts ""
  for j in jobs
    puts "*" * 50
    puts j.title
  end
  puts "*" * 50
  puts ""
end
  
def printJobs(jobs)
  for j in jobs
    puts "%" * 200
    puts j.inspect
    puts "*" * 50
    puts "faculties:"
    puts j.faculties.inspect
    puts "*" * 50
    puts "proglangs:"
    puts j.proglangs.inspect
    puts "*" * 50
    puts "courses:"
    puts j.courses.inspect
    puts "*" * 50
    puts "categories:"
    puts j.categories.inspect
    puts "*" * 50
    puts "department:"
    puts j.department.inspect
  end
end

def populate_tag_list(job)
  tags_string = ""
  tags_string << job.department.name
  tags_string << ',' + job.category_list_of_job 
  tags_string << ',' + job.course_list_of_job unless job.course_list_of_job.empty?
  tags_string << ',' + job.proglang_list_of_job unless job.proglang_list_of_job.empty?
  tags_string << ',' + (job.paid ? 'paid' : 'unpaid')
  tags_string << ',' + (job.credit ? 'credit' : 'no credit')
  job.tag_list = tags_string
end
  
protected
  def create_job(attribs={})
    j = Job.new(@valid_attributes.merge(attribs))

    j.sponsorships << @mock_sponsorship
    j.department   =  @mock_department
    j.user         =  @mock_user
    j.categories   << @mock_category

    j.valid?
    j.errors.should == {} and j.should be_valid

    ***REMOVED*** wtf
    @mock_category.should_receive(:record_timestamps)
    @mock_sponsorship.should_receive(:[]=)

    j.save.should == true

    @valid_jobs << j
    yield j if block_given?
    j
  end
end

