require 'spec_helper'

describe SearchableDateRange do

  describe "overlapping_with?" do

    before :each do
      @dr1 = SearchableDateRange.new
      @dr2 = SearchableDateRange.new
      @dr1.start_time = nil
      @dr1.end_time = nil
      @dr2.start_time = nil
      @dr2.end_time = nil
      @dr1.starts_at = nil
      @dr1.ends_at = nil
      @dr2.starts_at = nil
      @dr2.ends_at = nil
    end

    describe "where DR2 has dow+time range but DR1 has only datetime ranges" do
      it "should be false if DR2's time falls within the date range but the dow does not fall within the 3 day date range" do
        @dr2.start_time = 780 # 1pm
        @dr2.end_time = 900 # 3pm
        @dr2.dow = 4 # thursday

        @dr1.starts_at = Time.zone.now.beginning_of_week + 840.minutes # starts monday at 2pm
        @dr1.ends_at = Time.zone.now.beginning_of_week + 2.days + 960.minutes # ends wednesday at 4pm

        @dr1.should_not be_overlapping_with([@dr2])
      end
    end

  end

  describe "overlapping_times_with?" do

    before :each do
      @dr1 = SearchableDateRange.new
      @dr2 = SearchableDateRange.new
      @dr1.start_time = nil
      @dr1.end_time = nil
      @dr2.start_time = nil
      @dr2.end_time = nil
      @dr1.starts_at = nil
      @dr1.ends_at = nil
      @dr2.starts_at = nil
      @dr2.ends_at = nil
    end

    describe "where both DRs have times set" do
      it "should be true if DR1 is inside DR2" do
        @dr1.start_time = 300
        @dr1.end_time = 500
        @dr2.start_time = 100
        @dr2.end_time = 1000

        @dr1.should be_overlapping_times_with(@dr2)
      end
      it "should be true if DR2 is inside DR1" do
        @dr2.start_time = 300
        @dr2.end_time = 500
        @dr1.start_time = 100
        @dr1.end_time = 1000

        @dr1.should be_overlapping_times_with(@dr2)
      end
      it "should be true if DR2 overlaps DR1 on the left" do
        @dr1.start_time = 300
        @dr1.end_time = 700
        @dr2.start_time = 200
        @dr2.end_time = 400

        @dr1.should be_overlapping_times_with(@dr2)
      end
      it "should be true if DR2 overlaps DR1 on the right" do
        @dr1.start_time = 300
        @dr1.end_time = 700
        @dr2.start_time = 500
        @dr2.end_time = 1000

        @dr1.should be_overlapping_times_with(@dr2)
      end
      it "should be true if DR2 and DR1 are the same" do
        @dr2.start_time = @dr1.start_time = 300
        @dr2.end_time = @dr1.end_time = 700

        @dr1.should be_overlapping_times_with(@dr2)
      end
      it "should be false if DR1 and DR2 do not intersect/overlap" do
        @dr1.start_time = 100
        @dr1.end_time = 200
        @dr2.start_time = 201
        @dr2.end_time = 300

        @dr1.should_not be_overlapping_times_with(@dr2)
      end
    end

    describe "where DR2 has dow+time range but DR1 has only datetime ranges" do
      it "should be true if DR2's dow and time falls within the date range and the date range is 1 day long" do
        @dr2.start_time = 780 # 1pm
        @dr2.end_time = 900 # 3pm
        @dr2.dow = 2 # tuesday

        @dr1.starts_at = Time.zone.now.beginning_of_week + 1.day + 840.minutes # starts tuesday at 2pm
        @dr1.ends_at = Time.zone.now.beginning_of_week + 1.day + 960.minutes # ends tuesday at 4pm 

        @dr1.should be_overlapping_times_with(@dr2)
      end
      it "should be false if DR2's dow falls within the date range but the time of day does not fall within the 1 day date range" do
        @dr2.start_time = 975 # 4:15pm
        @dr2.end_time = 1080 # 6:00pm
        @dr2.dow = 2 # tuesday

        @dr1.starts_at = Time.zone.now.beginning_of_week + 1.day + 840.minutes # starts tuesday at 2pm
        @dr1.ends_at = Time.zone.now.beginning_of_week + 1.day + 960.minutes # ends tuesday at 4pm

        @dr1.should_not be_overlapping_times_with(@dr2)
      end
      it "should be true if the time falls within the middle of the date range and the date range is 3 days long" do
        @dr2.start_time = 780 # 1pm
        @dr2.end_time = 900 # 3pm
        @dr2.dow = 2 # tuesday

        @dr1.starts_at = Time.zone.now.beginning_of_week + 840.minutes # starts monday at 2pm
        @dr1.ends_at = Time.zone.now.beginning_of_week + 2.days + 960.minutes # ends wednesday at 4pm

        @dr1.should be_overlapping_times_with(@dr2)
      end
    end

    describe "where DR1 has dates but DR2 has default times" do
      it "should be true if the dow falls within the date range and the date range is 1 day long" do
        @dr2.dow = 2 # tuesday
        @dr1.starts_at = Time.zone.now.beginning_of_week + 1.day
        @dr1.ends_at = Time.zone.now.beginning_of_week + 1.day + 3.hours
        @dr1.should be_overlapping_dates_with(@dr2)
      end
      it "should be true if the dow falls within the middle of the date range and the date range is 3 days long" do
        @dr2.dow = 1 # monday
        @dr1.starts_at = Time.zone.now.beginning_of_week - 1.day # sunday (0)
        @dr1.ends_at = Time.zone.now.beginning_of_week + 1.day # tuesday (2)
        @dr1.should be_overlapping_dates_with(@dr2)
      end
      it "should be false if the dow does not fall within the 3 day date range" do
        @dr2.dow = 3 # wednesday
        @dr1.starts_at = Time.zone.now.beginning_of_week - 1.day # sunday (0)
        @dr1.ends_at = Time.zone.now.beginning_of_week + 1.day # tuesday (2)
        @dr1.should_not be_overlapping_dates_with(@dr2)
      end
    end

    describe "where DR1 has default times and DR2 has a default times" do
      it "should be true if both the dows are the same" do
        @dr1.dow = 1
        @dr2.dow = 1

        @dr1.should be_overlapping_dates_with(@dr2)
      end
      it "should be false if both the dows are not the same" do
        @dr1.dow = 1
        @dr2.dow = 2

        @dr1.should_not be_overlapping_dates_with(@dr2)
      end
    end

    describe "where DR1 and DR2 both do not have times set" do
      it "should return false" do
        @dr1.should_not be_overlapping_dates_with(@dr2)
      end
    end

    describe "where one of DR1 or DR2 do not have times set" do
      it "should return false" do
        @dr1.starts_at = 2.days.from_now
        @dr1.should_not be_overlapping_dates_with(@dr2)

        @dr1.starts_at = nil
        @dr1.ends_at = nil
        @dr2.starts_at = 4.days.from_now
        @dr1.should_not be_overlapping_dates_with(@dr2)
      end
    end
  end

  
  describe "overlapping_dates_with?" do

    before :each do
      @dr1 = SearchableDateRange.new
      @dr2 = SearchableDateRange.new
      @dr1.starts_at = nil
      @dr1.ends_at = nil
      @dr2.starts_at = nil
      @dr2.ends_at = nil
    end
    
    describe "where both DRs have dates set" do
      it "should be true if DR1 is inside DR2" do
        @dr1.starts_at = 5.days.from_now
        @dr1.ends_at = 6.days.from_now
        @dr2.starts_at = 3.days.from_now
        @dr2.ends_at = 7.days.from_now
        
        @dr1.should be_overlapping_dates_with(@dr2)
      end
      it "should be true if DR2 is inside DR1" do
        @dr1.starts_at = 3.days.from_now
        @dr1.ends_at = 7.days.from_now
        @dr2.starts_at = 5.days.from_now
        @dr2.ends_at = 6.days.from_now

        @dr1.should be_overlapping_dates_with(@dr2)
      end
      it "should be true if DR2 overlaps DR1 on the left" do
        @dr1.starts_at = 3.days.from_now
        @dr1.ends_at = 7.days.from_now
        @dr2.starts_at = 2.days.from_now
        @dr2.ends_at = 4.days.from_now
        
        @dr1.should be_overlapping_dates_with(@dr2)
      end
      it "should be true if DR2 overlaps DR1 on the right" do
        @dr1.starts_at = 3.days.from_now
        @dr1.ends_at = 7.days.from_now
        @dr2.starts_at = 5.days.from_now
        @dr2.ends_at = 10.days.from_now

        @dr1.should be_overlapping_dates_with(@dr2)
      end
      it "should be true if DR2 and DR1 are the same" do
        @dr2.starts_at = @dr1.starts_at = 3.days.from_now
        @dr2.ends_at = @dr1.ends_at = 7.days.from_now
        
        @dr1.should be_overlapping_dates_with(@dr2)
      end
      it "should be false if DR1 and DR2 do not intersect/overlap" do
        @dr1.starts_at = 1.days.from_now
        @dr1.ends_at = 2.days.from_now
        @dr2.starts_at = 2.days.from_now + 1.minute
        @dr2.ends_at = 3.days.from_now

        @dr1.should_not be_overlapping_dates_with(@dr2)
      end
    end

    describe "where DR2 has dates but DR1 has a dow" do
      it "should be true if the dow falls within the date range and the date range is 1 day long" do
        @dr1.dow = 2 # tuesday
        @dr2.starts_at = Time.zone.now.beginning_of_week + 1.day
        @dr2.ends_at = Time.zone.now.beginning_of_week + 1.day + 3.hours
        @dr1.should be_overlapping_dates_with(@dr2)
      end
      it "should be true if the dow falls within the middle of the date range and the date range is 3 days long" do
        @dr1.dow = 1 # monday
        @dr2.starts_at = Time.zone.now.beginning_of_week - 1.day # sunday (0)
        @dr2.ends_at = Time.zone.now.beginning_of_week + 1.day # tuesday (2)
        @dr1.should be_overlapping_dates_with(@dr2)
      end
      it "should be false if the dow does not fall within the 3 day date range" do
        @dr1.dow = 3 # wednesday
        @dr2.starts_at = Time.zone.now.beginning_of_week - 1.day # sunday (0)
        @dr2.ends_at = Time.zone.now.beginning_of_week + 1.day # tuesday (2)
        @dr1.should_not be_overlapping_dates_with(@dr2)
      end
    end

    describe "where DR1 has dates but DR2 has a dow" do
      it "should be true if the dow falls within the date range and the date range is 1 day long" do
        @dr2.dow = 2 # tuesday
        @dr1.starts_at = Time.zone.now.beginning_of_week + 1.day
        @dr1.ends_at = Time.zone.now.beginning_of_week + 1.day + 3.hours
        @dr1.should be_overlapping_dates_with(@dr2)
      end
      it "should be true if the dow falls within the middle of the date range and the date range is 3 days long" do
        @dr2.dow = 1 # monday
        @dr1.starts_at = Time.zone.now.beginning_of_week - 1.day # sunday (0)
        @dr1.ends_at = Time.zone.now.beginning_of_week + 1.day # tuesday (2)
        @dr1.should be_overlapping_dates_with(@dr2)
      end
      it "should be false if the dow does not fall within the 3 day date range" do
        @dr2.dow = 3 # wednesday
        @dr1.starts_at = Time.zone.now.beginning_of_week - 1.day # sunday (0)
        @dr1.ends_at = Time.zone.now.beginning_of_week + 1.day # tuesday (2)
        @dr1.should_not be_overlapping_dates_with(@dr2)
      end
    end

    describe "where DR1 has dow and DR2 has a dow" do
      it "should be true if both the dows are the same" do
        @dr1.dow = 1
        @dr2.dow = 1

        @dr1.should be_overlapping_dates_with(@dr2)
      end
      it "should be false if both the dows are not the same" do
        @dr1.dow = 1
        @dr2.dow = 2

        @dr1.should_not be_overlapping_dates_with(@dr2)
      end
    end

    describe "where DR1 and DR2 both do not have dates nor dow set" do
      it "should return false" do
        @dr1.should_not be_overlapping_dates_with(@dr2)
      end
    end

    describe "where one of DR1 or DR2 do not have dates nor dow set" do
      it "should return false" do
        @dr1.starts_at = 2.days.from_now
        @dr1.should_not be_overlapping_dates_with(@dr2)

        @dr1.starts_at = nil
        @dr1.ends_at = nil
        @dr2.starts_at = 4.days.from_now
        @dr1.should_not be_overlapping_dates_with(@dr2)
      end
    end
  end
end
