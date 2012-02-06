class ChatsController < ApplicationController
  before_filter :check_talk_restrictions
  
  def show
  end
  
  protected
  
  def check_talk_restrictions
    if current_character.restrict_fighting?
      render 'characters/restrictions', :locals => { :restriction_type => :talking }
    end
  end
end