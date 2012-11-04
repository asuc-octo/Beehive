require 'spec_helper'

describe "/categories/index.html.erb" do
  include CategoriesHelper

  before(:each) do
    assigns[:categories] = [
      stub_model(Category,
        :name => "value for name",
        :job => 1
      ),
      stub_model(Category,
        :name => "value for name",
        :job => 1
      )
    ]
  end

  it "renders a list of categories" do
   ***REMOVED*** render
    ***REMOVED***response.should have_tag("tr>td", "value for name".to_s, 2)
   ***REMOVED*** response.should have_tag("tr>td", 1.to_s, 2)
  end
end
