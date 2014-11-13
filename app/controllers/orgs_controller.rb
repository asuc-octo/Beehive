class OrgsController < ApplicationController

  ***REMOVED*** Only logged in users can view this page
  before_filter :goto_home_unless_logged_in
  before_filter :rm_login_required

  ***REMOVED*** Only users in the org can modify it
  before_filter :correct_user_access, :only => [:edit, :update]

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
    @org = Org.find(params[:id])

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
    @org = Org.find(params[:id])
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
    @org = Org.find(params[:id])

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

  ***REMOVED*** DELETE /orgs/1
  ***REMOVED*** DELETE /orgs/1.json
  def destroy
    @org = Org.find(params[:id])
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
    if (Org.find(params[:id]) == nil || (!@current_user.admin? and !Org.find(params[:id]).members.include(@current_user)))
      flash[:error] = "You don't have permissions to edit or delete that org."
      redirect_to :controller => 'dashboard', :action => :index
    end
  end
end
