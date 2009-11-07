class PicturesController < ApplicationController
  ***REMOVED*** GET /pictures
  ***REMOVED*** GET /pictures.xml
  def index
    @pictures = Picture.all

    respond_to do |format|
      format.html ***REMOVED*** index.html.erb
      format.xml  { render :xml => @pictures }
    end
  end

  ***REMOVED*** GET /pictures/1
  ***REMOVED*** GET /pictures/1.xml
  def show
    @picture = Picture.find(params[:id])

    respond_to do |format|
      format.html ***REMOVED*** show.html.erb
      format.xml  { render :xml => @picture }
    end
  end

  ***REMOVED*** GET /pictures/new
  ***REMOVED*** GET /pictures/new.xml
  def new
    @picture = Picture.new

    respond_to do |format|
      format.html ***REMOVED*** new.html.erb
      format.xml  { render :xml => @picture }
    end
  end

  ***REMOVED*** GET /pictures/1/edit
  def edit
    @picture = Picture.find(params[:id])
  end

  ***REMOVED*** POST /pictures
  ***REMOVED*** POST /pictures.xml
  def create
    @picture = Picture.new(params[:picture])

    respond_to do |format|
      if @picture.save
        flash[:notice] = 'Picture was successfully created.'
        format.html { redirect_to(@picture) }
        format.xml  { render :xml => @picture, :status => :created, :location => @picture }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @picture.errors, :status => :unprocessable_entity }
      end
    end
  end

  ***REMOVED*** PUT /pictures/1
  ***REMOVED*** PUT /pictures/1.xml
  def update
    @picture = Picture.find(params[:id])

    respond_to do |format|
      if @picture.update_attributes(params[:picture])
        flash[:notice] = 'Picture was successfully updated.'
        format.html { redirect_to(@picture) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @picture.errors, :status => :unprocessable_entity }
      end
    end
  end

  ***REMOVED*** DELETE /pictures/1
  ***REMOVED*** DELETE /pictures/1.xml
  def destroy
    @picture = Picture.find(params[:id])
    @picture.destroy

    respond_to do |format|
      format.html { redirect_to(pictures_url) }
      format.xml  { head :ok }
    end
  end
end
