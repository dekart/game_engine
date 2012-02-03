class ChatsController < ApplicationController
  def show
    if current_character.restrict_talking?
      redirect_to root_url
    end
  end
end