require 'spec_helper'

describe Contest do
  
  describe 'scopes' do
    before do
      @character1 = Factory(:character)
      @character2 = Factory(:character)
      
      @contest = Factory(:contest)
    end
    
    it 'should not return current contest if contest not published' do
      Contest.current.should be_empty
    end
    
    it 'should return current not started contests' do
      @contest.started_at = 1.hour.since
      @contest.save!
      
      @contest.publish!
      
      Contest.current.should == [@contest]
    end
    
    it 'should return current started contests' do
      @contest.started_at = 1.hour.ago
      @contest.save!
      
      @contest.publish!
      
      Contest.current.should == [@contest]
    end
    
    it 'should return contests finished less than 5 days ago' do
      @contest.started_at = Time.now
      @contest.save!
      
      @contest.publish!
      
      Timecop.travel(1.day.since) do
        @contest.finish!
      end
      
      Contest.current.should == [@contest]
    end
    
    it 'should not return contests finished more than 5 days ago' do
      @contest.started_at = Time.now
      @contest.save!
      
      @contest.publish!
      
      Timecop.travel((5.days + 1.hour).since) do
        @contest.finish!
      end
      
      Contest.current.should be_empty
    end
  end
  
  describe 'methods' do
    before do
      @contest = Factory(:contest)
      
      @character_contest1 = Factory(:character_contest, :contest => @contest)
      @character_contest2 = Factory(:character_contest, :contest => @contest)
    end
    
    it 'should return contest leaders_with_points' do
      @character_contest1.update_attribute(:points, 1)
      
      @contest.leaders_with_points.should == [@character_contest1, @character_contest2]
    end
    
    it 'should limit leaders_with_points' do
      @character_contest1.update_attribute(:points, 1)
      
      @contest.leaders_with_points(:limit => 1).should == [@character_contest1]
    end
    
    it 'should return positions of character in rating' do
      @character_contest1.update_attribute(:points, 1)
      
      @contest.position(@character_contest1.character).should == 1
      @contest.position(@character_contest2.character).should == 2
    end
    
    it 'should return last position of character that not participate in contest' do
      @non_participant = Factory(:character)
      
      @contest.position(@non_participant).should == @contest.characters.count + 1
    end
    
    it 'should return time left to start contest' do
      Timecop.freeze(Time.now) do
        @contest.started_at = 1.day.since
        @contest.save!
        
        @contest.time_left_to_start.should == 1.day.to_i
      end
    end
    
    it 'should return time left to finish contest' do
      Timecop.freeze(Time.now) do
        @contest.finished_at = 1.day.since
        @contest.save!
        
        @contest.time_left_to_finish.should == 1.day.to_i
      end
    end
    
    it 'should increment character points' do
      @contest.started_at = 1.hours.ago
      @contest.save!
      
      @contest.publish!
      
      @contest.inc_points!(@character_contest1.character)
      @character_contest1.reload.points.should == 1
    end
    
    it 'should not increment character points if contest finish time has come' do
      @contest.started_at = 1.hours.ago
      @contest.save!
      
      @contest.publish!
      
      @contest.finished_at = 1.minute.ago
      @contest.save!
      
      @contest.inc_points!(@character_contest1.character)
      @character_contest1.reload.points.should == 0
    end
    
    it 'should return result object for character' do
      @contest.result_for(@character_contest1.character).should == @character_contest1
      @contest.result_for(@character_contest2.character).should == @character_contest2
    end
  end
  
  describe 'when creating' do
    before do
      @contest = Factory(:contest)
    end
    
    it 'should be hidden' do
      @contest.hidden?.should be_true
    end
    
    it 'should not be started' do
      @contest.started?.should be_false
    end
    
    it 'should not be started soon' do
      @contest.starting_soon?.should be_false
    end
  end
  
  describe 'when publish' do
    before do
      @contest = Factory(:contest)
    end
    
    it 'should not be published without start time' do
      @contest.can_publish?.should be_false
    end
    
    it 'should be published after setting start time' do
      @contest.update_attribute(:started_at, 1.hour.since)
      
      @contest.can_publish?.should be_true
    end
    
    it 'should successfully published' do
      @contest.update_attribute(:started_at, 1.hour.since)
      
      @contest.publish.should be_true
    end
    
    it 'should sets contest finish time' do
      @contest.update_attribute(:started_at, 1.hour.since)
      
      Timecop.freeze(Time.now) do
        lambda {
          @contest.publish!
        }.should change(@contest, :finished_at).from(nil).to(@contest.started_at + @contest.duration_time.days)
      end
    end
  end
  
  describe 'when finished' do
    before do
      @contest = Factory(:contest, :started_at => 1.hour.since)
      @contest.publish!
    end
    
    it 'should set finish time' do
      Timecop.freeze(Time.now) do
        lambda {
          @contest.finish!
        }.should change(@contest, :finished_at).from(@contest.started_at + @contest.duration_time.days).to(Time.now)
      end
    end
  end
  
  describe 'when mark deleted' do
    before do
      @contest = Factory(:contest)
    end
    
    it 'should be mark deleted' do
      @contest.mark_deleted!
      @contest.deleted?.should be_true
    end
  end
  
  describe 'fights' do
    before do
      @attacker = Factory(:character)
      @victim   = Factory(:character)
      
      @fight = Fight.new(:attacker => @attacker, :victim => @victim)
      
      @contest = Factory(:contest, :started_at => Time.now)
    end
    
    it 'should not increment points if contest not published' do
      @fight.stub!(:attacker_won?).and_return(true)
      
      @fight.save!
      
      @contest.result_for(@attacker).should be_nil
      @contest.result_for(@victim).should be_nil
    end
    
    it 'should increment points if character won fight' do
      @fight.stub!(:attacker_won?).and_return(true)
      
      @contest.publish!
      
      @fight.save!
      
      @contest.result_for(@attacker).points.should == 1
      @contest.result_for(@victim).should be_nil
    end
    
    it 'should not increment points if character lost fight' do
      @fight.stub!(:attacker_won?).and_return(false)
      
      @contest.publish!
      
      @fight.save!
      
      @contest.result_for(@attacker).should be_nil
      @contest.result_for(@victim).should be_nil
    end
  end
end