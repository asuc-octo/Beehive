class JobsController < ApplicationController
  ***REMOVED*** GET /jobs
  ***REMOVED*** GET /jobs.xml
  
  ***REMOVED*** Ensures that only logged-in users can create, edit, or delete jobs
  before_filter :login_required, :except => [ :index, :show, :list ]
  
  def index
    @search_query = "keyword (leave blank to view all)"
	***REMOVED***@search_query = params[:search_terms][:query]
	***REMOVED***@department = params[:search_terms][:department]
	***REMOVED***@faculty = params[:search_terms][:faculty]
	***REMOVED***@paid = params[:search_terms][:paid]
	***REMOVED***@credit = params[:search_terms][:credit]
	
	***REMOVED***@department ||= 0
	***REMOVED***@faculty ||= 0
	***REMOVED***@paid ||= 0
	***REMOVED***@credit ||= 0
	
    ***REMOVED*** Commenting out active condition for testing purposes (because activation hasn't been implemented)
    ***REMOVED***@jobs = Job.find(:all, :conditions => [ "active = ?", true ])
	@jobs = Job.find(:all, :order=> "created_at DESC")
	@departments = Department.all
    respond_to do |format|
      format.html ***REMOVED*** index.html.erb
      format.xml  { render :xml => @jobs }
    end
  end
  
  def list
	@search_query = "keyword (leave blank to view all)"
	d_id = params[:department_select]
	
	params[:search_terms] ||= {}
	query = params[:search_terms][:query]
	department = params[:search_terms][:department_select].to_i
	faculty = params[:search_terms][:faculty_select].to_i
	paid = params[:search_terms][:paid].to_i
	credit = params[:search_terms][:credit].to_i

	if(query && !query.empty? && (query != @search_query))
		***REMOVED***Commenting out active condition for testing purposes (because activation hasn't been implemented)
		***REMOVED***@jobs = Job.find_by_solr(query).results.select { |c| c.active == true } ***REMOVED*** How to filter these results pre-query through solr?  Should actually be filtered through solr, not here.
		puts "found something"
		@jobs = Job.find_by_solr(query).results
		
	else
		***REMOVED***flash[:notice] = 'Your query was invalid and could not return any results.'
		@jobs = Job.find(:all, :order=>"created_at DESC")
	end ***REMOVED***end params[:query]
	

	@jobs = @jobs.select {|j| j.department_id.to_i == department } if department != 0
	@jobs = @jobs.select {|j| j.faculties.collect{|f| f.id.to_i}.include?(faculty) }  if faculty != 0
	@jobs = @jobs.select {|j| j.paid } if paid != 0
	@jobs = @jobs.select {|j| j.credit } if credit != 0
	
	respond_to do |format|
		format.html { render :action => :index, :query => query, :department => department, :faculty => faculty, :paid => paid, :credit => credit }
		format.xml { render :xml => @jobs }
	end
		
  end
    
  ***REMOVED*** GET /jobs/1
  ***REMOVED*** GET /jobs/1.xml
  def show
    @job = Job.find(params[:id])

    respond_to do |format|
      format.html ***REMOVED*** show.html.erb
      format.xml  { render :xml => @job }
    end
  end

  ***REMOVED*** GET /jobs/new
  ***REMOVED*** GET /jobs/new.xml
  def new
    @job = Job.new
	
    @all_faculty = Faculty.find(:all)
    @faculty_names = []
    @all_faculty.each do |faculty|
      @faculty_names << faculty.name
    end
	
  end

  ***REMOVED*** GET /jobs/1/edit
  def edit
    @job = Job.find(params[:id])
	
    @all_faculty = Faculty.find(:all)
    @faculty_names = []
    @all_faculty.each do |faculty|
      @faculty_names << faculty.name
    end

  end

  ***REMOVED*** POST /jobs
  ***REMOVED*** POST /jobs.xml
  def create
	
	params[:job][:user] = current_user
	params[:job][:activation_code] = (rand(99999) + 100000)*100000000000 + Time.now.to_i ***REMOVED*** Generates a random 7 digit number and appends the result the current UNIX time to that number.
	params[:job][:active] = false
	sponsorships = []
	@job = Job.new(params[:job])
	@sponsorship = Sponsorship.new(:faculty => Faculty.find(params[:faculty_name]), :job => @job)
	@job.sponsorships = sponsorships << @sponsorship
	
    respond_to do |format|
      if @job.save
		***REMOVED***@sponsorship.save
        flash[:notice] = 'Thank you for submitting a job.  Before this job can be added to our listings page and be viewed by other users, it must be approved by the faculty sponsor.  An e-mail has been dispatched to the faculty sponsor with instructions on how to activate this job.  Once activated, users will be able to browse and respond to the job posting.'
		
		***REMOVED*** Send an e-mail to the faculty member(s) involved.
		
		***REMOVED***FacultyMailer.deliver_faculty_confirmer(found_faculty.email, found_faculty.name, @job.id, @job.title, @job.desc, @job.activation_code)
		
        format.html { redirect_to(@job) }
        format.xml  { render :xml => @job, :status => :created, :location => @job }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
      end
    end
  end

  ***REMOVED*** PUT /jobs/1
  ***REMOVED*** PUT /jobs/1.xml
  def update
	***REMOVED***params[:job][:sponsorships] = Sponsorship.new(:faculty => Faculty.find(:first, :conditions => [ "name = ?", params[:job][:faculties] ]), :job => nil)	
    @job = Job.find(params[:id])

    @all_faculty = Faculty.find(:all)
    @faculty_names = []
    @all_faculty.each do |faculty|
      @faculty_names << faculty.name
    end
	
    respond_to do |format|
      if @job.update_attributes(params[:job])
        flash[:notice] = 'Job was successfully updated.'
        format.html { redirect_to(@job) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
      end
    end
  end

  ***REMOVED*** DELETE /jobs/1
  ***REMOVED*** DELETE /jobs/1.xml
  def destroy
    @job = Job.find(params[:id])
    @job.destroy

    respond_to do |format|
      format.html { redirect_to(jobs_url) }
      format.xml  { head :ok }
    end
  end
  
  def activate
    ***REMOVED*** /jobs/activate/job_id?a=xxx
	@job = Job.find(:first, :conditions => [ "activation_code = ? AND active = ?", params[:a], false ])
	respond_to do |format|
		if @job
		  @job.active = true
		  @job.save
		  flash[:notice] = 'Job activated successfully.  Your job is now available to be browsed and viewed by other users.'
		  format.html { redirect_to(@job) }
		else
		  flash[:notice] = 'Unsuccessful activation.  Either this job has already been activated or the activation code is incorrect.'
		  format.html { redirect_to(jobs_url) }
		end
	end
  end
end