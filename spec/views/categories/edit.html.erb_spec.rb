require 'spec_helper'

describe "/categories/edit.html.erb" do
  include CategoriesHelper

  before(:each) do
    assigns[:category] = @category = stub_model(Category,
      :new_record? => false,
      :name => "value for name",
      :job => 1
    )
  end

  it "renders the edit category form" do
   ***REMOVED*** render

    ***REMOVED***response.should have_tag("form[action=***REMOVED***{category_path(@category)}][method=post]") do
    ***REMOVED***  with_tag('input***REMOVED***category_name[name=?]', "category[name]")
    ***REMOVED***  with_tag('input***REMOVED***category_job[name=?]', "category[job]")
    ***REMOVED***end
  end
end
