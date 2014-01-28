require 'spec_helper'

describe "/categories/new.html.erb" do
  include CategoriesHelper

  before(:each) do
    assigns[:category] = stub_model(Category,
      :new_record? => true,
      :name => "value for name",
      :job => 1
    )
  end

  it "renders new category form" do
    ***REMOVED***render

    ***REMOVED***response.should have_tag("form[action=?][method=post]", categories_path) do
    ***REMOVED***  with_tag("input***REMOVED***category_name[name=?]", "category[name]")
    ***REMOVED***  with_tag("input***REMOVED***category_job[name=?]", "category[job]")
    ***REMOVED***end
  end
end
