class HitListingsController < ApplicationController
  def index
    @hit_listings = HitListing.incomplete.scoped(
      :include  => [:victim, :client],
      :limit    => Setting.i(:hit_list_display_limit)
    )
  end

  def new
    @victim = Character.find(params[:character_id])

    @hit_listing = current_character.ordered_hit_listings.build(
      :victim => @victim,
      :reward => Setting.i(:hit_list_minimum_reward)
    )
  end

  def create
    @victim = Character.find(params[:character_id])

    @hit_listing = current_character.ordered_hit_listings.build(
      :victim => @victim,
      :reward => params[:hit_listing][:reward]
    )

    if @hit_listing.save
      render :action => :create
    else
      render :action => :new
    end
  end

  def update
    @hit_listing = HitListing.find(params[:id])

    @result = @hit_listing.execute!(current_character)
  end
end
