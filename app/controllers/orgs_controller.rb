class OrgsController < ApplicationController

  ***REMOVED*** Only logged in users can view this page
  before_filter :rm_login_required

  ***REMOVED*** Only users in the org can modify it
  before_filter :correct_user_access, :only => [:edit, :update, :curate]

  ***REMOVED*** Only admins can create or delete orgs
  before_filter :require_admin, :only => [:new, :create, :destroy]

  ***REMOVED*** GET /orgs
  ***REMOVED*** GET /orgs.json
  def index
    @orgs = Org.all

    respond_to do |format|
      format.html ***REMOVED*** index.html.erb
      format.json { render json: @orgs }
    end
  end

  ***REMOVED*** GET /orgs/1
  ***REMOVED*** GET /orgs/1.json
  def show
    @org = Org.from_param(params[:abbr])
    ***REMOVED*** @jobs = Job.find(Curation.where(:org_id => @org.id).pluck(:job_id))
    @jobs = @org.jobs
    respond_to do |format|
      format.html ***REMOVED*** show.html.erb
      format.json { render json: @org }
    end
  end

  ***REMOVED*** GET /orgs/new
  ***REMOVED*** GET /orgs/new.json
  def new
    @org = Org.new

    respond_to do |format|
      format.html ***REMOVED*** new.html.erb
      format.json { render json: @org }
    end
  end

  ***REMOVED*** GET /orgs/1/edit
  def edit
    @org = Org.from_param(params[:abbr])
  end

  ***REMOVED*** POST /orgs
  ***REMOVED*** POST /orgs.json
  def create
    @org = Org.new(params[:org])

    respond_to do |format|
      if @org.save
        format.html { redirect_to @org, notice: 'Org was successfully created.' }
        format.json { render json: @org, status: :created, location: @org }
      else
        format.html { render action: "new" }
        format.json { render json: @org.errors, status: :unprocessable_entity }
      end
    end
  end

  ***REMOVED*** PUT /orgs/1
  ***REMOVED*** PUT /orgs/1.json
  def update
    @org = Org.from_param(params[:abbr])

    respond_to do |format|
      if @org.update_attributes(params[:org])
        format.html { redirect_to @org, notice: 'Org was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @org.errors, status: :unprocessable_entity }
      end
    end
  end

  ***REMOVED*** GET /orgs/1/curate?job_id=2
  def curate
    curate = Curation.new({:org => Org.from_param(params[:abbr]), :job_id => params[:job_id], :user=> @current_user})
    if curate.save
      flash[:notice] = 'Successfully curated listing.'
    else
      flash[:notice] = 'Was not able to curate this listing. Perhaps you\'ve already curated it?'
    end
    redirect_to(:back)
  end

  def uncurate
    curate = Curation.where({:org_id => Org.from_param(params[:abbr]), :job_id => params[:job_id]})
    if curate.destroy_all
      flash[:notice] = 'Successfully uncurated listing.'
    else
      flash[:notice] = 'Was not able to uncurate this listing. Perhaps you haven\'t curated it?'
    end
    redirect_to(:back)
  end

  ***REMOVED*** DELETE /orgs/1
  ***REMOVED*** DELETE /orgs/1.json
  def destroy
    @org = Org.from_param(params[:abbr])
    @org.destroy

    respond_to do |format|
      format.html { redirect_to orgs_url }
      format.json { head :no_content }
    end
  end

***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED***     FILTERS      ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***

  private
  def correct_user_access
    org = Org.from_param(params[:abbr])
    if (!org || (!@current_user.admin? and !org.members.include?(@current_user)))
      flash[:error] = "You don't have permissions to edit or delete that org."
      redirect_to :controller => 'dashboard', :action => :index
    end
  end
end
