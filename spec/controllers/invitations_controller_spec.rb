# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include Devise::TestHelpers # to give your spec access to helpers

describe InvitationsController do
  before(:each) do
    @event = Factory.create :event
    @user = @event.user
    @rsvp = @event.rsvps.first

    @other_users = (1..25).map { [ Factory.create(:user), Factory.create(:user_with_sign_in) ] }.flatten

    @connections = @other_users.each{|ou| @user.connections.create(:to_user=>ou)}

    request.env['warden'] = mock(Warden, :authenticate => @user,
      :authenticate! => @user)
  end

  describe "Spec settings" do
    it "should have 27 signed in users" do
      # => Create signed in users for pagination testing
      # => 25 fake users, 1 event user, 1 rsvp user
      User.has_signed_in.count.should == 27
    end

    it "should have 25 users that have never signed in" do
      # => Creating non signed in users so that some are not selected
      User.where("sign_in_count=0").count.should == 25
    end
  end

  describe "GET /new WITHOUT PARAMS" do
    before { get :new, :event_id => @event.id, :rsvp_id=>@rsvp.id}

    it "should have the user setup" do
      assigns(:current_user).should == @user
    end


    it "should setup @event" do
      assigns(:event).should == @event
    end

    it "should setup @rsvp" do
      assigns(:rsvp).should == @rsvp
    end

    it "should have setup @users" do
      assigns(:users).should_not be_nil
    end

    it "should have set @per_page to 10" do
      assigns[:per_page].should == 10
    end

    it "should have offset of 0" do
      assigns[:offset].should == 0
    end

    it "should have a @total_count equal to (user connections and signed in users).uniq" do
      assigns[:total_count].should == ((@user.connections.collect(&:to_user) + User.has_signed_in.all.to_a) - [@user]).uniq.size
    end

    it "should have User.count / 10 number of pages" do
      assigns[:num_pages].should == (assigns[:total_count].to_f / assigns[:per_page].to_f).ceil
    end

    it "should have @users with a count of 10" do
      assigns[:users].all.size.should == 10
    end

    it "should have @invitations set" do
      assigns[:invitations].should_not be_nil
    end

    it "should have @number of invitations set to what was invited" do
      @other_users.first(10).each{|ou| @rsvp.invitations.create(:event=>@event, :user=>@user, :to_user=>ou)}
      assigns[:invitations].count.should == 10
    end

    it "should render new" do
      response.should render_template("new")
    end
    
  end

  describe "GET /new WITH PARAMS" do
    
    it "should have only user with exact search" do
      get :new, :event_id => @event.id, :rsvp_id=>@rsvp.id, :user_search=>@other_users[10].email
      assigns[:users].all.size.should == 1
    end

    it "should have total_count of all users except current_user when search is 'Person'" do
      get :new, :event_id => @event.id, :rsvp_id=>@rsvp.id, :user_search=>'Person'
      assigns[:total_count].should ==  ((@user.connections.collect(&:to_user) + User.has_signed_in.to_a) - [@user]).uniq.size
    end

    it "should return less than all users when search is 'Person \\w'" do
      get :new, :event_id => @event.id, :rsvp_id=>@rsvp.id, :user_search=>"Person #{@other_users[10].last_name[0..-2]}"
      assigns[:total_count].should < ((@user.connections.collect(&:to_user) + User.has_signed_in.to_a) - [@user]).uniq.size
    end

    it "should have an offset of 10 when page = 2" do
      get :new, :event_id => @event.id, :rsvp_id=>@rsvp.id, :page=>2
      assigns[:offset].should == 10
    end

    it "should render new" do
      get :new, :event_id => @event.id, :rsvp_id=>@rsvp.id, :page=>2
      response.should render_template("new")
    end


  end

  describe "GET /change WITH PARAMS" do

    it "should have only user with exact search" do
      get :change, :event_id => @event.id, :rsvp_id=>@rsvp.id, :user_search=>@other_users[10].email
      assigns[:users].all.size.should == 1
    end

    it "should have total_count of all users except current_user when search is 'Person'" do
      get :change, :event_id => @event.id, :rsvp_id=>@rsvp.id, :user_search=>'Person'
      assigns[:total_count].should ==  ((@user.connections.collect(&:to_user) + User.has_signed_in.to_a) - [@user]).uniq.size
    end

    it "should return less than all users when search is 'Person \\w'" do
      get :change, :event_id => @event.id, :rsvp_id=>@rsvp.id, :user_search=>"Person #{@other_users[10].last_name[0..-2]}"
      assigns[:total_count].should < ((@user.connections.collect(&:to_user) + User.has_signed_in.to_a) - [@user]).uniq.size
    end

    it "should have an offset of 10 when page = 2" do
      get :change, :event_id => @event.id, :rsvp_id=>@rsvp.id, :page=>2
      assigns[:offset].should == 10
    end

    it "should render change" do
      get :change, :event_id => @event.id, :rsvp_id=>@rsvp.id, :page=>2
      response.should render_template("change")
    end

  end

  describe "XHR /new WITH PARAMS" do

    it "should render user_results with page param" do
      xhr :get, :new, :event_id => @event.id, :rsvp_id=>@rsvp.id, :page=>2
      response.should render_template("_user_results")
    end

  end

  describe "XHR /change WITHOUT PARAMS" do

    it "should render /new" do
      xhr :get, :change, :event_id => @event.id, :rsvp_id=>@rsvp.id
      response.should render_template("new")
    end

  end
  
end
