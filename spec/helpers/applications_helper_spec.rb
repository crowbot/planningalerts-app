require 'spec_helper'

describe ApplicationsHelper do
  before :each do
    authority = mock_model(Authority, :full_name => "An authority", :short_name => "Blue Mountains")
    @application = mock_model(Application, :map_url => "http://a.map.url",
      :description => "A planning application", :council_reference => "A1", :authority => authority, :info_url => "http://info.url", :comment_url => "http://comment.url",
      :on_notice_from => nil, :on_notice_to => nil)
  end

  describe "scraped_and_received_text" do
    before :each do
      @application.stub!(:address).and_return("foo")
      @application.stub!(:lat).and_return(1.0)
      @application.stub!(:lng).and_return(2.0)
      @application.stub!(:location).and_return(Location.new(1.0, 2.0))
    end

    it "should say when the application was received by the planning authority and when it appeared on PlanningAlerts" do
      @application.stub!(:date_received).and_return(20.days.ago)
      @application.stub!(:date_scraped).and_return(18.days.ago)
      helper.scraped_and_received_text(@application).should ==
        "We found this application for you on the planning authority's website 18 days ago. It was received by them 2 days earlier."
    end

    it "should say something appropriate when the received date is not known" do
      @application.stub!(:date_received).and_return(nil)
      @application.stub!(:date_scraped).and_return(18.days.ago)
      helper.scraped_and_received_text(@application).should ==
        "We found this application for you on the planning authority's website 18 days ago. The date it was received by them was not recorded."
    end
  end

  describe "on_notice_text" do
    before :each do
      @application.stub!(:address).and_return("foo")
      @application.stub!(:lat).and_return(1.0)
      @application.stub!(:lng).and_return(2.0)
      @application.stub!(:location).and_return(Location.new(1.0, 2.0))
      @application.stub!(:date_received).and_return(nil)
      @application.stub!(:date_scraped).and_return(Time.now)
    end

    it "should say when the application is on notice (and hasn't started yet)" do
      @application.stub!(:on_notice_from).and_return(Date.today + 2.days)
      @application.stub!(:on_notice_to).and_return(Date.today + 16.days)
      helper.on_notice_text(@application).should ==
        "The period for officially responding to this application starts <strong>in 2 days</strong> and finishes 14 days later."
    end

    describe "period has just started" do
      it "should say when the application is on notice" do
        @application.stub!(:on_notice_from).and_return(Date.today)
        @application.stub!(:on_notice_to).and_return(Date.today + 14.days)
        helper.on_notice_text(@application).should ==
          "You have <strong>14 days</strong> left to officially respond to this application. The period for comment started today."
      end

      it "should say when the application is on notice" do
        @application.stub!(:on_notice_from).and_return(Date.today - 1.day)
        @application.stub!(:on_notice_to).and_return(Date.today + 13.days)
        helper.on_notice_text(@application).should ==
          "You have <strong>13 days</strong> left to officially respond to this application. The period for comment started yesterday."
      end
    end

    describe "period is pending" do
      before :each do
        @application.stub!(:on_notice_from).and_return(Date.today - 2.days)
        @application.stub!(:on_notice_to).and_return(Date.today + 12.days)
      end

      it "should say when the application is on notice" do
        helper.on_notice_text(@application).should ==
          "You have <strong>12 days</strong> left to officially respond to this application. The period for comment started 2 days ago."
      end

      it "should only say when on notice to if there is no on notice from information" do
        @application.stub!(:on_notice_from).and_return(nil)
        helper.on_notice_text(@application).should ==
          "You have <strong>12 days</strong> left to officially respond to this application."
      end
    end

    describe "period is finishing today" do
      it "should say when the application is on notice" do
        @application.stub!(:on_notice_from).and_return(Date.today - 14.day)
        @application.stub!(:on_notice_to).and_return(Date.today)
        helper.on_notice_text(@application).should ==
          "<strong>Today</strong> is the last day to officially respond to this application. The period for comment started 14 days ago."
      end
    end

    describe "period is finished" do
      before :each do
        @application.stub!(:on_notice_from).and_return(Date.today - 16.days)
        @application.stub!(:on_notice_to).and_return(Date.today - 2.days)
      end

      it "should say when the application is on notice" do
        helper.on_notice_text(@application).should ==
          "You're too late! The period for officially commenting on this application finished <strong>2 days ago</strong>. It lasted for 14 days. If you chose to comment now, your comment will still be displayed here and be sent to the planning authority but it will <strong>not be officially considered</strong> by the planning authority."
      end

      it "should only say when on notice to if there is no on notice from information" do
        @application.stub!(:on_notice_from).and_return(nil)
        helper.on_notice_text(@application).should ==
          "You're too late! The period for officially commenting on this application finished <strong>2 days ago</strong>. If you chose to comment now, your comment will still be displayed here and be sent to the planning authority but it will <strong>not be officially considered</strong> by the planning authority."
      end
    end

    describe "static maps" do
      before :each do
        @application.stub!(:address).and_return("Foo Road, NSW")
      end

      it "should generate a static google map api image" do
        helper.google_static_map(@application, :size => "350x200", :zoom => 16).should ==
          "<img alt=\"Map of Foo Road, NSW\" height=\"200\" src=\"http://maps.googleapis.com/maps/api/staticmap?zoom=16&size=350x200&maptype=roadmap&markers=color:red%7C1.0,2.0&sensor=false\" width=\"350\" />"
        helper.google_static_map(@application, :size => "100x100", :zoom => 14).should ==
          "<img alt=\"Map of Foo Road, NSW\" height=\"100\" src=\"http://maps.googleapis.com/maps/api/staticmap?zoom=14&size=100x100&maptype=roadmap&markers=color:red%7C1.0,2.0&sensor=false\" width=\"100\" />"
      end
    end

    describe "static streetview" do
      before :each do
        @application.stub!(:address).and_return("Foo Road, NSW")
      end

      it "should generate a static google streetview image" do
        helper.google_static_streetview(@application, :size => "350x200", :fov => 90).should ==
          "<img alt=\"Streetview of Foo Road, NSW\" height=\"200\" src=\"http://maps.googleapis.com/maps/api/streetview?size=350x200&location=1.0,2.0&fov=90&sensor=false\" width=\"350\" />"
        helper.google_static_streetview(@application, :size => "100x100", :fov => 60).should ==
          "<img alt=\"Streetview of Foo Road, NSW\" height=\"100\" src=\"http://maps.googleapis.com/maps/api/streetview?size=100x100&location=1.0,2.0&fov=60&sensor=false\" width=\"100\" />"
      end
    end
  end
end
