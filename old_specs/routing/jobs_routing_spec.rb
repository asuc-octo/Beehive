require 'spec_helper'

describe JobsController do
  describe "routing" do
    it "recognizes and generates ***REMOVED***index" do
      { :get => "/jobs/list" }.should route_to(:controller => "jobs", :action => "index")
    end

    it "recognizes and generates ***REMOVED***new" do
      { :get => "/jobs/new" }.should route_to(:controller => "jobs", :action => "new")
    end

    it "recognizes and generates ***REMOVED***show" do
      { :get => "/jobs/1" }.should route_to(:controller => "jobs", :action => "show", :id => "1")
    end

    it "recognizes and generates ***REMOVED***edit" do
      { :get => "/jobs/1/edit" }.should route_to(:controller => "jobs", :action => "edit", :id => "1")
    end

    it "recognizes and generates ***REMOVED***create" do
      { :post => "/jobs" }.should route_to(:controller => "jobs", :action => "create") 
    end

    it "recognizes and generates ***REMOVED***update" do
      { :put => "/jobs/1" }.should route_to(:controller => "jobs", :action => "update", :id => "1") 
    end

    it "recognizes and generates ***REMOVED***destroy" do
      { :delete => "/jobs/1" }.should route_to(:controller => "jobs", :action => "destroy", :id => "1") 
    end
  end
end
