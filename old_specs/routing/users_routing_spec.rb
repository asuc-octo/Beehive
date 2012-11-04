require 'spec_helper'

describe UsersController do
  describe "routing" do
    it "recognizes and generates ***REMOVED***index" do
      { :get => "/users" }.should route_to(:controller => "users", :action => "index")
    end

    it "recognizes and generates ***REMOVED***new" do
      ***REMOVED***{ :get => "/users/new" }.should route_to(:controller => "users", :action => "new")
    end

    it "recognizes and generates ***REMOVED***show" do
      { :get => "/users/1" }.should route_to(:controller => "users", :action => "show", :id => "1")
    end

    it "recognizes and generates ***REMOVED***edit" do
      { :get => "/users/1/edit" }.should route_to(:controller => "users", :action => "edit", :id => "1")
    end

    it "recognizes and generates ***REMOVED***create" do
      ***REMOVED***{ :post => "/users" }.should route_to(:controller => "users", :action => "create") 
    end

    it "recognizes and generates ***REMOVED***update" do
      { :put => "/users/1" }.should route_to(:controller => "users", :action => "update", :id => "1") 
    end

    it "recognizes and generates ***REMOVED***destroy" do
      { :delete => "/users/1" }.should route_to(:controller => "users", :action => "destroy", :id => "1") 
    end
  end
end
