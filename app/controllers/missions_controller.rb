class MissionsController < ApplicationController
  def index
    @missions = Mission.find(:all)
  end
end
