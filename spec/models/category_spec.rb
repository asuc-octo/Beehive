require 'spec_helper'

describe Category do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :job_id => 1
    }
  end

  ***REMOVED***
  ***REMOVED*** Validation
  ***REMOVED***
  
  it "should create a new instance given valid attributes" do
    Category.create!(@valid_attributes)
  end
end
