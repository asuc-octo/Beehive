require 'spec_helper'

describe "/categories/show.html.erb" do
  include CategoriesHelper
  before(:each) do
    assigns[:category] = @category = stub_model(Category,
      :name => "value for name",
      :job => 1
    )
  end

  it "renders attributes in <p>" do
    ***REMOVED***render
    ***REMOVED***response.should have_text(/value\ for\ name/)
    ***REMOVED***response.should have_text(/1/)
  end
end
