require 'spec_helper'

describe ContestGroup do
  describe 'when creating' do
    before :each do
      @contest = Factory(:contest) 
      @contest_group = @contest.groups.first
    end
    
    it 'should validate presence of contest' do 
      @contest_group.should validate_presence_of(:contest_id)
    end
    
    it 'should validate numericality of max_character_level' do
      @contest_group.should validate_numericality_of(:max_character_level)
    end
    
    it 'should validate uniqueness of max_character_level' do
      @contest_group.should validate_uniqueness_of(:max_character_level).scoped_to(:contest_id)
    end
  end
  
  describe 'points' do
    before do
      @contest = Factory(:contest) 
      @contest_group = @contest.groups.first
      
      @character_contest_group1 = Factory(:character_contest_group, :contest_group => @contest_group)
      @character_contest_group2 = Factory(:character_contest_group, :contest_group => @contest_group)
    end
    
    it 'should return contest leaders_with_points' do
      @character_contest_group1.update_attribute(:points, 1)
      
      @contest_group.leaders_with_points.should == [@character_contest_group1, @character_contest_group2]
    end
    
    it 'should limit leaders_with_points' do
      @character_contest_group1.update_attribute(:points, 1)
      
      @contest_group.leaders_with_points(:limit => 1).should == [@character_contest_group1]
    end
    
    it 'should return positions of character in rating' do
      @character_contest_group1.update_attribute(:points, 1)
      
      @contest.position(@character_contest_group1.character).should == 1
      @contest.position(@character_contest_group2.character).should == 2
    end
    
    it 'should return last position of character that not participate in contest' do
      @non_participant = Factory(:character)
      
      @contest.position(@non_participant).should == @contest_group.characters.count + 1
    end
    
    it 'should return result object for character' do
      @contest.result_for(@character_contest_group1.character).should == @character_contest_group1
      @contest.result_for(@character_contest_group2.character).should == @character_contest_group2
    end
  end
  
  describe 'payouts' do
    before do
      @contest = Factory(:contest) 
      @contest_group = @contest.groups.first
      
      @contest_group.payouts = Payouts::Collection.new(
        Payouts::BasicMoney.new(:value => 100, :apply_on => :first),
        Payouts::BasicMoney.new(:value => 50, :apply_on => :second),
        Payouts::BasicMoney.new(:value => 10, :apply_on => :third)
      )
      @contest_group.save!
      
      @character = Factory(:character)
      
      @contest.started_at = 1.minute.ago
      
      @contest.publish!
    end

    it 'should not apply payouts to losers' do
      lambda {
        @contest_group.apply_payouts!
      }.should_not change{@character.reload.basic_money}
    end
    
    it 'should apply payouts to winners' do
      @contest.inc_points!(@character)
      
      lambda {
        @contest_group.apply_payouts!
      }.should change{@character.reload.basic_money}.by(100)
    end
    
    it 'should apply payouts only for 3 winners' do
      @second_winner = Factory(:character)
      @third_winner = Factory(:character)
      @loser = Factory(:character)
      
      @contest.inc_points!(@character, 3)
      @contest.inc_points!(@second_winner, 2)
      @contest.inc_points!(@third_winner)
      
      @contest.apply_payouts!.should == [@character, @second_winner, @third_winner]
    end
    
    it 'should apply payouts for winners' do
      @second_winner = Factory(:character)
      @third_winner = Factory(:character)
      @loser = Factory(:character)
      
      @contest.inc_points!(@character, 3)
      @contest.inc_points!(@second_winner, 2)
      @contest.inc_points!(@third_winner)
      
      @contest.apply_payouts!
      
      @character.reload.basic_money.should == 100
      @second_winner.reload.basic_money.should == 50
      @third_winner.reload.basic_money.should == 10
      
      @loser.reload.basic_money.should == 0
    end
  end
  
  describe '#methods' do
    before do
      @contest = Factory(:contest)
      
      @contest_group1 = @contest.groups.create!(:max_character_level => 5)
      @contest_group2 = @contest.groups.create!(:max_character_level => 10)
      @contest_group3 = @contest.groups.first
    end
    
    it 'should select previous group if it exists' do
      @contest_group1.previous_group.should be_nil
      
      @contest_group2.previous_group.should == @contest_group1
      
      @contest_group3.previous_group.should == @contest_group2
    end
    
    it 'should display start level' do
      @contest_group1.start_level.should == 1
      
      @contest_group2.start_level.should == 6
      
      @contest_group3.start_level.should == 11
    end
    
    it 'should display title' do
      @contest_group1.title.should == "1-5"
      
      @contest_group2.title.should == "6-10"
      
      @contest_group3.title.should == "11+"
    end
  end
end