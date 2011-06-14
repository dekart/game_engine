require 'spec_helper'

describe Contest do
  
  describe 'validators' do
  end
  
  describe 'scopes' do
    before do
      @character1 = Factory(:character)
      @character2 = Factory(:character)
      
      @contest = Factory(:contest)
    end
    
    it 'should return current contests'
    it 'should return contest leaders'
  end
  
  describe 'when creating' do
    before do
      @contest = Factory(:contest)
    end
    
    it 'should not be published without start time' do
      @contest.can_publish?.shoud be_false
    end
  end
  
  describe 'when publish' do
    before do
      @contest = Factory(:contest, :started_at => 1.hour.since)
    end
    
    it 'should be published after setting start time' do
      @contest.can_publish?.should be_true
    end
    
    it 'should successfully published' do
      @contest.publish.should be_true
    end
  end
  
  describe 'when finished' do
    before do
      @contest = Factory(:contest)
    end
    
    it 'should set current finish time when contest finished' do
      Timecop.freeze(Time.now) do
        lambda {
          @contest.finish
        }.should change(@contest, :finished_at).from(nil).to(Time.now)
      end
    end
  end
  
  describe 'when deleted' do
    
  end
end