class BossesController < ApplicationController
  def show
    @boss = Boss.find(params[:id])
  end
end
