class JobsController < ApplicationController
  ***REMOVED*** GET /jobs
  ***REMOVED*** GET /jobs.xml
  
  ***REMOVED*** Ensures that only logged-in users can create, edit, or delete jobs
  before_filter :login_required, :except => [ :index, :show, :list ]
  
  def index
    @jobs = Job.all

    respond_to do |format|
      format.html ***REMOVED*** index.html.erb
      format.xml  { render :xml => @jobs }
    end
  end
  
  def list
	d_id = params[:department_select]
	
	query = params[:search_terms][:query]
	if(query && !query.empty?)
		@jobs = Job.find_by_solr(query).results
else
	
	if(d_id == "0")
		@department = "All Departments"
		@jobs = Job.all
	else
		@department = Department.find(d_id).name
		@jobs = Job.all
	end
	
end ***REMOVED***end params[:query]

	respond_to do |format|
		format.html { render :action => :index }
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

    respond_to do |format|
      format.html ***REMOVED*** new.html.erb
      format.xml  { render :xml => @job }
    end
  end

  ***REMOVED*** GET /jobs/1/edit
  def edit
    @job = Job.find(params[:id])
  end

  ***REMOVED*** POST /jobs
  ***REMOVED*** POST /jobs.xml
  def create
	params[:job][:user] = current_user
    @job = Job.new(params[:job])

    respond_to do |format|
      if @job.save
        flash[:notice] = 'Job was successfully created.'
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
    @job = Job.find(params[:id])

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
end
