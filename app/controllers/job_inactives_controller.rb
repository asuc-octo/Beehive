class JobInactivesController < ApplicationController
  ***REMOVED*** GET /job_inactives
  ***REMOVED*** GET /job_inactives.xml
  def index
    @job_inactives = JobInactive.all

    respond_to do |format|
      format.html ***REMOVED*** index.html.erb
      format.xml  { render :xml => @job_inactives }
    end
  end

  ***REMOVED*** GET /job_inactives/1
  ***REMOVED*** GET /job_inactives/1.xml
  def show
    @job_inactive = JobInactive.find(params[:id])

    respond_to do |format|
      format.html ***REMOVED*** show.html.erb
      format.xml  { render :xml => @job_inactive }
    end
  end

  ***REMOVED*** GET /job_inactives/new
  ***REMOVED*** GET /job_inactives/new.xml
  def new
    @job_inactive = JobInactive.new

    respond_to do |format|
      format.html ***REMOVED*** new.html.erb
      format.xml  { render :xml => @job_inactive }
    end
  end

  ***REMOVED*** GET /job_inactives/1/edit
  def edit
    @job_inactive = JobInactive.find(params[:id])
  end

  ***REMOVED*** POST /job_inactives
  ***REMOVED*** POST /job_inactives.xml
  def create
    @job_inactive = JobInactive.new(params[:job_inactive])

    respond_to do |format|
      if @job_inactive.save
        flash[:notice] = 'JobInactive was successfully created.'
        format.html { redirect_to(@job_inactive) }
        format.xml  { render :xml => @job_inactive, :status => :created, :location => @job_inactive }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @job_inactive.errors, :status => :unprocessable_entity }
      end
    end
  end

  ***REMOVED*** PUT /job_inactives/1
  ***REMOVED*** PUT /job_inactives/1.xml
  def update
    @job_inactive = JobInactive.find(params[:id])

    respond_to do |format|
      if @job_inactive.update_attributes(params[:job_inactive])
        flash[:notice] = 'JobInactive was successfully updated.'
        format.html { redirect_to(@job_inactive) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @job_inactive.errors, :status => :unprocessable_entity }
      end
    end
  end

  ***REMOVED*** DELETE /job_inactives/1
  ***REMOVED*** DELETE /job_inactives/1.xml
  def destroy
    @job_inactive = JobInactive.find(params[:id])
    @job_inactive.destroy

    respond_to do |format|
      format.html { redirect_to(job_inactives_url) }
      format.xml  { head :ok }
    end
  end
  
  ***REMOVED*** GET /activate_job/1
  def activate
    @job_inactive = JobInactive.find(:activation_code => params[:code])
	if @job_inactive
	  ***REMOVED*** -----
	  @job_active = Job.new(:user => @job_inactive.user, :title => @job_inactive.title, :desc => @job_inactive.desc, :category => @job_inactive.category, :exp_date => @job_inactive.exp_date, :num_positions => @job_inactive.num_positions, :paid => @job_inactive.paid, :credit => @job_inactive.credit)
	  @job_active.save
	  redirect_to(@job_active)
	else
	  ***REMOVED*** render an error page
	end
  end
end
