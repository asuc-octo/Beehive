require 'spec_helper'

describe "/jobs/show.html.erb" do
  include JobsHelper
  before(:each) do
	@job = stub_model(Job,
      :user => 1,
      :title => "value for title",
      :desc => "value for desc",
      :category => 1,
      :num_positions => 1,
      :paid => false,
      :credit => false
    )
	@user = stub_model(User, {})
	@job.stub!(:user).and_return(@user)
    assigns[:job] = @job
	
  end

  it "renders attributes in <p>" do
    render
    ***REMOVED***response.should have_text(/1/)
    ***REMOVED***response.should have_text(/value\ for\ title/)
    ***REMOVED***response.should have_text(/value\ for\ desc/)
    ***REMOVED***response.should have_text(/1/)
    ***REMOVED***response.should have_text(/1/)
    ***REMOVED***response.should have_text(/false/)
    ***REMOVED***response.should have_text(/false/)
  end
end
