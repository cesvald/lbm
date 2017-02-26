require "spec_helper"

describe IniciativesController do
  describe "routing" do

    it "routes to #index" do
      get("/iniciatives").should route_to("iniciatives#index")
    end

    it "routes to #new" do
      get("/iniciatives/new").should route_to("iniciatives#new")
    end

    it "routes to #show" do
      get("/iniciatives/1").should route_to("iniciatives#show", :id => "1")
    end

    it "routes to #edit" do
      get("/iniciatives/1/edit").should route_to("iniciatives#edit", :id => "1")
    end

    it "routes to #create" do
      post("/iniciatives").should route_to("iniciatives#create")
    end

    it "routes to #update" do
      put("/iniciatives/1").should route_to("iniciatives#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/iniciatives/1").should route_to("iniciatives#destroy", :id => "1")
    end

  end
end
