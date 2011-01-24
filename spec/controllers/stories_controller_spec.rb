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
    
    it 'should try to fetch story from the database' do
      Story.should_receive(:find_by_id).with('123').and_return(@story)
      
      get :show, :id => 123
    end
    
    describe 'when there is a story with given ID' do
      before do
        Story.stub!(:find_by_id).and_return(@story)
      end
      
      it 'should track character\'s visit to the story' do
        @story.should_receive(:track_visit!).with(@character).and_return([])
        
        get :show, :id => 123
      end
      
      describe 'if visit tracking gave some payouts' do
        before do
          @story.stub!(:track_visit!).and_return(Payouts::Collection.new(DummyPayout.new))
        end
        
        it 'should display a page with story payout results' do
          get :show, :id => 123
          
          response.should render_template(:show)
        end
        
        it 'should pass next page url to the template' do
          get :show, :id => 123
          
          assigns[:next_page].should == 'http://apps.facebook.com/test/'
        end
      end

      it 'should redirect to next page if there were no payouts' do
        get :show, :id => 123
        
        response.should redirect_from_iframe_to('http://apps.facebook.com/test/')
      end
      
      
    end
    
    describe 'when ID is a default story alias' do
      it 'should target to home page from level up story' do
        get :show, :id => 'level_up'
        
        response.should redirect_from_iframe_to('http://apps.facebook.com/test/')
      end
      
      it 'should target to shop page from inventory story' do
        get :show, :id => 'inventory'
        
        response.should redirect_from_iframe_to('http://apps.facebook.com/test/items')
      end
      
      it 'should target to mission help page from mission help request story'
      it 'should target to mission group page from mission completion story'
      it 'should target to mission group page from boss story'
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