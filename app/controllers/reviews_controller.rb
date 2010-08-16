class ReviewsController < ApplicationController
  ***REMOVED*** GET /reviews
  ***REMOVED*** GET /reviews.xml
  
  ***REMOVED*** Ensures that only logged-in users can create, edit, or delete reviews
  before_filter :login_required, :except => [ :index, :show ]
  
  ***REMOVED*** Ensures that only the user who created a review -- and no other users -- can edit it 
  before_filter :correct_user_access, :only => [ :edit, :update, :destroy ]
  
  def index
    @reviews = Review.all

    respond_to do |format|
      format.html ***REMOVED*** index.html.erb
      format.xml  { render :xml => @reviews }
    end
  end

  ***REMOVED*** GET /reviews/1
  ***REMOVED*** GET /reviews/1.xml
  def show
    @review = Review.find(params[:id])

    respond_to do |format|
      format.html ***REMOVED*** show.html.erb
      format.xml  { render :xml => @review }
    end
  end

  ***REMOVED*** GET /reviews/new
  ***REMOVED*** GET /reviews/new.xml
  def new
    @review = Review.new

    respond_to do |format|
      format.html ***REMOVED*** new.html.erb
      format.xml  { render :xml => @review }
    end
  end

  ***REMOVED*** GET /reviews/1/edit
  def edit
    @review = Review.find(params[:id])
  end

  ***REMOVED*** POST /reviews
  ***REMOVED*** POST /reviews.xml
  def create
	***REMOVED*** First, handle the params not explicitly assigned
	***REMOVED*** in the 'new' view's form.

	  params[:review][:user] = current_user

	  handle_faculty		***REMOVED*** this line must come before the one following it!
    @review = Review.new(params[:review])

    respond_to do |format|
      if @review.save
        flash[:notice] = 'Review was successfully created.'
        format.html { redirect_to(@review) }
        format.xml  { render :xml => @review, :status => :created, :location => @review }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @review.errors, :status => :unprocessable_entity }
      end
    end
  end

  ***REMOVED*** PUT /reviews/1
  ***REMOVED*** PUT /reviews/1.xml
  def update
    @review = Review.find(params[:id])
	  handle_faculty
	
    respond_to do |format|
      if @review.update_attributes(params[:review])
        flash[:notice] = 'Review was successfully updated.'
        format.html { redirect_to(@review) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @review.errors, :status => :unprocessable_entity }
      end
    end
  end

  ***REMOVED*** DELETE /reviews/1
  ***REMOVED*** DELETE /reviews/1.xml
  def destroy
    @review = Review.find(params[:id])
    @review.destroy

    respond_to do |format|
      format.html { redirect_to(reviews_url) }
      format.xml  { head :ok }
    end
  end
  
  ***REMOVED*** extra handlers used in more than one CRUD method
  protected
	def handle_faculty
		if params[:faculty_name]
			params[:review][:faculty] = Faculty.find_by_name(params[:faculty_name])
		end
	end
	
  private
	def correct_user_access
		if (Review.find(params[:id]) == nil || current_user != Review.find(params[:id]).user)
			flash[:notice] = "Unauthorized access denied. Do not pass Go. Do not collect $200."
			redirect_to :controller => 'reviews', :action => :index
		end
	end
  
end
