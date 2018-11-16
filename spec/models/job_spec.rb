require 'rails_helper'

RSpec.describe Job, type: :model do
  it "should have title" do
  	FactoryBot.build(:job, title:nil).should_not be_valid
  end

  it "should have project type" do
  	FactoryBot.build(:job, title:nil).should_not be_valid
  end

  it "should have department" do
  	FactoryBot.build(:job, department:nil).should_not be_valid
  end

  it "should have description" do
  	FactoryBot.build(:job, desc:nil).should_not be_valid
  end

  it "should have earliest date" do
  	FactoryBot.build(:job, earliest_start_date:nil).should_not be_valid
  end

  it "should have latest start date" do
  	FactoryBot.build(:job, latest_start_date:nil).should_not be_valid
  end

  it "should have end date" do
  	FactoryBot.build(:job, end_date:nil).should_not be_valid
  end

  it "earliest date must be before latest start date" do
  	FactoryBot.build(:latest_lessthan_earliest).should_not be_valid
  end

  it "latest start date must be before end date" do
  	FactoryBot.build(:end_lessthan_latest).should_not be_valid
  end

  it "factory default entry should be valid" do
  	FactoryBot.create(:job).should be_valid
  end

end
