require 'spec_helper'

describe PicturesController do
  describe "routing" do
    it "recognizes and generates ***REMOVED***index" do
      { :get => "/pictures" }.should route_to(:controller => "pictures", :action => "index")
    end

    it "recognizes and generates ***REMOVED***new" do
      { :get => "/pictures/new" }.should route_to(:controller => "pictures", :action => "new")
    end

    it "recognizes and generates ***REMOVED***show" do
      { :get => "/pictures/1" }.should route_to(:controller => "pictures", :action => "show", :id => "1")
    end

    it "recognizes and generates ***REMOVED***edit" do
      { :get => "/pictures/1/edit" }.should route_to(:controller => "pictures", :action => "edit", :id => "1")
    end

    it "recognizes and generates ***REMOVED***create" do
      { :post => "/pictures" }.should route_to(:controller => "pictures", :action => "create") 
    end

    it "recognizes and generates ***REMOVED***update" do
      { :put => "/pictures/1" }.should route_to(:controller => "pictures", :action => "update", :id => "1") 
    end

    it "recognizes and generates ***REMOVED***destroy" do
      { :delete => "/pictures/1" }.should route_to(:controller => "pictures", :action => "destroy", :id => "1") 
    end
  end
end
