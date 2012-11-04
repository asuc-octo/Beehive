require 'spec_helper'

describe "/users/new.html.erb" do
  include UsersHelper

  before(:each) do
    assigns[:user] = stub_model(User,
      :new_record? => true
    )
  end

  it "renders new user form" do
    ***REMOVED***render

    ***REMOVED***response.should have_tag("form[action=?][method=post]", users_path) do
    ***REMOVED***end
  end
end
