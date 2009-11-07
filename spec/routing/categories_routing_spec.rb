require 'spec_helper'

describe CategoriesController do
  describe "routing" do
    it "recognizes and generates ***REMOVED***index" do
      { :get => "/categories" }.should route_to(:controller => "categories", :action => "index")
    end

    it "recognizes and generates ***REMOVED***new" do
      { :get => "/categories/new" }.should route_to(:controller => "categories", :action => "new")
    end

    it "recognizes and generates ***REMOVED***show" do
      { :get => "/categories/1" }.should route_to(:controller => "categories", :action => "show", :id => "1")
    end

    it "recognizes and generates ***REMOVED***edit" do
      { :get => "/categories/1/edit" }.should route_to(:controller => "categories", :action => "edit", :id => "1")
    end

    it "recognizes and generates ***REMOVED***create" do
      { :post => "/categories" }.should route_to(:controller => "categories", :action => "create") 
    end

    it "recognizes and generates ***REMOVED***update" do
      { :put => "/categories/1" }.should route_to(:controller => "categories", :action => "update", :id => "1") 
    end

    it "recognizes and generates ***REMOVED***destroy" do
      { :delete => "/categories/1" }.should route_to(:controller => "categories", :action => "destroy", :id => "1") 
    end
  end
end
