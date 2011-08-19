require 'spec_helper'

describe Contest do
  
  describe 'scopes' do
    before do
      @character1 = Factory(:character)
      @character2 = Factory(:character)
      
      @contest = Factory(:contest)
    end
    
    it 'should not return current contest if contest not published' do
      Contest.current.should be_nil
    end
    
    it 'should return current not started contests' do
      @contest.started_at = 1.hour.ago
      @contest.save!
      
      @contest.publish!
      
      Contest.current.should == @contest
    end
    
    it 'should return current started contests' do
      @contest.started_at = 1.hour.ago
      @contest.save!
      
      @contest.publish!
      
      Contest.current.should == @contest
    end
    
    it 'should return contests finished less than 5 days ago' do
      @contest.started_at = Time.now
      @contest.save!
      
      @contest.publish!
      
      Timecop.travel(1.day.ago) do
        @contest.finish!
      end
      
      Contest.finished_recently.should == [@contest]
    end
    
    it 'should not return contests finished more than 5 days ago' do
      @contest.started_at = Time.now
      @contest.save!
      
      @contest.publish!
      
      Timecop.travel((5.days + 1.hour).ago) do
        @contest.finish!
      end
      
      Contest.finished_recently.should be_empty
    end
  end
  
  describe 'methods' do
    before do
      @contest = Factory(:contest) 
      @contest_group = @contest.groups.first
      
      @character = Factory(:character)
    end
    
    it 'should return time left to start contest' do
      Timecop.freeze(Time.now) do
        @contest.started_at = 1.day.from_now
        @contest.save!
        
        @contest.time_left_to_start.should == 1.day.to_i
      end
    end
    
    it 'should return time left to finish contest' do
      Timecop.freeze(Time.now) do
        @contest.finished_at = 1.day.from_now
        @contest.save!
        
        @contest.time_left_to_finish.should == 1.day.to_i
      end
    end
    
    it 'should increment character points' do
      @contest.started_at = 1.hours.ago
      @contest.save!
      
      @contest.publish!
      
      @contest.inc_points!(@character)
      @contest.result_for(@character).points.should == 1
    end
    
    it 'should not increment character points if contest finish time has come' do
      @contest.started_at = 1.hours.ago
      @contest.save!
      
      @contest.publish!
      
      @contest.finished_at = 1.minute.ago
      @contest.save!
      
      @contest.inc_points!(@character)
      @contest.result_for(@character).should be_nil
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
    
    it 'should create default contest group' do
      @contest.groups.length == 1
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
      @contest.update_attribute(:started_at, 1.hour.ago)
      
      @contest.can_publish?.should be_true
    end
    
    it 'should successfully published' do
      @contest.update_attribute(:started_at, 1.hour.ago)
      
      @contest.publish.should be_true
    end
    
    it 'should sets contest finish time' do
      @contest.update_attribute(:started_at, 1.hour.ago)
      
      Timecop.freeze(Time.now) do
        lambda {
          @contest.publish!
        }.should change(@contest, :finished_at).from(nil).to(@contest.started_at + @contest.duration_time.days)
      end
    end
  end
  
  describe 'when finished' do
    before do
      @contest = Factory(:contest, :started_at => 1.hour.ago)
      @contest.publish!
      
      @contest_group = @contest.groups.first
      
      @contest_group.payouts = Payouts::Collection.new(
        Payouts::BasicMoney.new(:value => 100, :apply_on => :first),
        Payouts::BasicMoney.new(:value => 50, :apply_on => :second),
        Payouts::BasicMoney.new(:value => 10, :apply_on => :third)
      )
      @contest_group.save!
      
      @character = Factory(:character)
    end
    
    it 'should set finish time if it finished before finished_at' do
      Timecop.freeze(Time.now) do
        lambda {
          @contest.finish!
        }.should change(@contest, :finished_at).from(@contest.started_at + @contest.duration_time.days).to(Time.now)
      end
    end
    
    it 'should not set finish time if it finished after finished_at' do
      Timecop.freeze(@contest.finished_at + 1.minute) do
        lambda {
          @contest.finish!
        }.should_not change(@contest, :finished_at)
      end
    end
    
    it 'should apply payouts to winners' do
      @character2 = Factory(:character)
      @character3 = Factory(:character)
      @character4 = Factory(:character)
      
      @contest.inc_points!(@character, 5)
      @contest.inc_points!(@character2, 4)
      @contest.inc_points!(@character3, 3)
      @contest.inc_points!(@character4, 2)
      
      @contest.finish!
      
      @character.reload.basic_money.should == 100
      @character2.reload.basic_money.should == 50
      @character3.reload.basic_money.should == 10
      
      @character4.reload.basic_money.should == 0
    end
      
    
    it 'should create notifications for winners' do
      @character2 = Factory(:character)
      @character3 = Factory(:character)
      
      @contest.inc_points!(@character)
      @contest.inc_points!(@character2)
      @contest.inc_points!(@character3)
      
      @contest.finish!
      
      @character.notifications.first.class.should == Notification::ContestWinner
      @character2.notifications.first.class.should == Notification::ContestWinner
      @character3.notifications.first.class.should == Notification::ContestWinner
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
      
      @contest = Factory(:contest, :started_at => Time.now, :points_type => 'fights_won')
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
  
  describe 'monsters' do
    before do
      @character = Factory(:character)
      
      @monster_fight = Factory(:monster_fight, :character => @character)
      
      @damage_system = mock('damage system', :calculate_damage => [10, 20])
      MonsterFight.stub!(:damage_system).and_return(@damage_system)
      
      @contest = Factory(:contest, :started_at => Time.now, :points_type => 'total_monsters_damage')
    end
    
    it 'should not increment points if contest not published' do
      @monster_fight.attack!
      @contest.result_for(@character).should be_nil
    end
    
    it 'should increment points if contest was starts and character make damage' do
      @contest.publish!
      
      @monster_fight.attack!
      
      @contest.result_for(@character).points.should == 20
    end
  end
  
  describe 'group_for selection' do
    before do
      @contest = Factory(:contest) 
      
      @contest_group1 = @contest.groups.first
      @contest_group2 = @contest.groups.create!(:max_character_level => 5)
      @contest_group3 = @contest.groups.create!(:max_character_level => 10)
      
      @character = Factory(:character, :level => 5)
      @high_level_character = Factory(:character, :level => 11)
      
      @contest.started_at = 1.minute.ago
      @contest.publish!
    end
    
    it 'should select appropriate group for character if they dont paricipate in contest' do
      @contest.group_for(@character).should == @contest_group2
      
      @contest.group_for(@high_level_character).should == @contest_group1
    end
    
    it 'should select appropriate group for character if they paricipate in contest' do
      @contest.inc_points!(@character)
      @contest.inc_points!(@high_level_character)
      
      @contest.group_for(@character).should == @contest_group2
      
      @contest.group_for(@high_level_character).should == @contest_group1
    end
    
    it 'characters should stay in groups where they started contest after level-ups' do
      @contest.inc_points!(@character)
      
      @character.update_attribute(:level, 6)
      
      @contest.group_for(@character).should == @contest_group2
    end
  end
end