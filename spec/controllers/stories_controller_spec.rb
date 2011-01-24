require 'spec_helper'

describe StoriesController do
  include FacebookSpecHelper
  
  before do
    controller.stub!(:current_facebook_user).and_return(fake_fb_user)
  end
  
  describe "when routing" do
    it "should correctly map to story page" do
      params_from(:get, "/stories/asd123").should == {
        :controller => "stories",
        :action     => "show",
        :id         => "asd123"
      }
    end
  end
  
  describe 'when visiting story' do
    before do
      @character = mock_model(Character)

      controller.stub!(:current_character).and_return(@character)

      @story = mock_model(Story, 
        :alias => 'somealias', 
        :track_visit! => []
      )
    end
    
    def do_request(options = {})
      get :show, options.reverse_merge(
        :id => 123, 
        :story_data => '"drDaHHyJrkDUN6vc5j6iTg4Qqj5mkwp93nEsCh3x/1w=--b7T0SRHS2i4vPs1MSU+txg=="' # {:character_id => 1}
      )
    end
    
    it 'should try to fetch story from the database' do
      Story.should_receive(:find_by_id).with('123').and_return(@story)
      
      do_request
    end
    
    describe 'when there is a story with given ID' do
      before do
        Story.stub!(:find_by_id).and_return(@story)
      end
      
      it 'should track character\'s visit to the story' do
        @story.should_receive(:track_visit!).with(@character, :character_id => 1).and_return([])
        
        do_request
      end
      
      describe 'if visit tracking gave some payouts' do
        before do
          @story.stub!(:track_visit!).and_return(Payouts::Collection.new(DummyPayout.new))
        end
        
        it 'should display a page with story payout results' do
          do_request
          
          response.should render_template(:show)
        end
        
        it 'should pass next page url to the template' do
          do_request
          
          assigns[:next_page].should == 'http://apps.facebook.com/test/'
        end
      end

      it 'should redirect to next page if there were no payouts' do
        do_request
        
        response.should redirect_from_iframe_to('http://apps.facebook.com/test/')
      end
    end
    
    describe 'when ID is a default story alias' do
      it 'should target to home page from level up story' do
        do_request :id => 'level_up'
        
        response.should redirect_from_iframe_to('http://apps.facebook.com/test/')
      end
      
      it 'should target to shop page from inventory story' do
        do_request :id => 'inventory'
        
        response.should redirect_from_iframe_to('http://apps.facebook.com/test/items')
      end
      
      it 'should target to mission help page from mission help request story'
      
      it 'should target to mission group page from mission completion story' do
        do_request(
          :id => 'mission',
          :story_data => '"yZc8QppPzioO7o7hLRlnPec83iaHzaHSsRuiGBAqP1eXId5HN6BWe2znPhnw+TI+--UKqsGv+yur295NLWzhjqbw=="' # {:mission_group_id => 1, :character_id => 1}
        )

        response.should redirect_from_iframe_to('http://apps.facebook.com/test/mission_groups/1')
      end
      
      it 'should target to mission group page from boss story' do
        do_request(
          :id => 'boss',
          :story_data => '"yZc8QppPzioO7o7hLRlnPec83iaHzaHSsRuiGBAqP1eXId5HN6BWe2znPhnw+TI+--UKqsGv+yur295NLWzhjqbw=="' # {:mission_group_id => 1, :character_id => 1}
        )

        response.should redirect_from_iframe_to('http://apps.facebook.com/test/mission_groups/1')
      end
      
      it 'should target to monster page from monster invitation story'
      it 'should target to monster page from monster defeat story'
      it 'should target to property list page from property purchase story'
      it 'should target to promotion page from promotion story'
      it 'should target to hitlist page from new hit listing story'
      it 'should target to hitlist page from completed hit listing story'
      it 'should target to collection list page from collection completion story'
      it 'should target to item giveout page from missing collection items story'
    end
  end
end