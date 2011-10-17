class Admin::FacultiesController < AdminController

  def index
    @faculties = Faculty.all
  end

  def update
    unless f = Faculty.find(params[:id])
      redirect_to admin_faculties_path, :notice => "Invalid id ***REMOVED***{params[:id]}"
    end

    unless f.update_attributes(params[:faculty])
      redirect_to admin_faculties_path, :notice => "Failed to update ***REMOVED***{f.inspect}"
    end

    redirect_to admin_faculties_path, :notice => "Successfully updated ***REMOVED***{f.name}"

  end

end
