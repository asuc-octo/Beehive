require 'spec_helper'

describe "/reviews/new.html.erb" do
  include ReviewsHelper

  before(:each) do
    assigns[:review] = stub_model(Review,
      :new_record? => true,
      :user => 1,
      :body => "value for body",
      :rating => 1
    )
  end

  it "renders new review form" do
    render

    response.should have_tag("form[action=?][method=post]", reviews_path) do
      with_tag("input***REMOVED***review_user[name=?]", "review[user]")
      with_tag("textarea***REMOVED***review_body[name=?]", "review[body]")
      with_tag("input***REMOVED***review_rating[name=?]", "review[rating]")
    end
  end
end
