require 'spec_helper'

describe UserGroupsController do

  describe "GET 'update.js'" do
    it "should be successful" do
      get 'update.js'
      response.should be_success
    end
  end

  describe "GET 'create.js'" do
    it "should be successful" do
      get 'create.js'
      response.should be_success
    end
  end

end
