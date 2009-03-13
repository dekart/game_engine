class CharactersController < ApplicationController
  def index
  end

  def upgrade
    if request.post?
      if current_character.upgrade_attribute!(params[:attribute])
        render :text => current_character.attributes[params[:attribute]]
      else
        render :text => "This attribute cannot be upgraded"
      end
    end
  end
end
