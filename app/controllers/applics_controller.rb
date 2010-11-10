class ApplicsController < ApplicationController
  def show
    @applic = Applic.find(params[:id])

    respond_to do |format|
      format.html ***REMOVED*** show.html.erb
      format.xml  { render :xml => @applic }
    end
  end
end
