class StoriesController < ApplicationController
  include StreamHelper

  def show
    story_data = encryptor.decrypt((params[:story_data] || params['amp;story_data']).to_s)

    if @story = Story.find_by_id(params[:id])
      @payouts = @story.track_visit!(current_character, story_data)

      @next_page = next_page_for_story(@story.alias, story_data)
    else
      @payouts = []

      @next_page = next_page_for_story(params[:id], story_data)
    end

    redirect_from_iframe(@next_page) if @payouts.empty?
  end

  def prepare
    case params[:id]
    when 'mission_help'
      render :json => stream_dialog_options(:mission_help, GameData::Mission[params[:mission_id]])
    end
  end

  protected

  def next_page_for_story(key, story_data)
    case key
    when 'item_purchased'
      items_url(:canvas => fb_canvas?)
    when 'mission_help'
      help_mission_url(story_data[:mission_id],
        :key => encryptor.encrypt(
          :mission_id   => story_data[:mission_id],
          :character_id => story_data[:character_id]
        ),
        :canvas => fb_canvas?
      )
    when 'mission_completed'
      mission_groups_url(:canvas => fb_canvas?)
    when 'monster_invite'
      monster_url(story_data[:monster_id],
        :key => encryptor.encrypt(story_data[:monster_id]),
        :canvas => fb_canvas?
      )
    when 'monster_defeated'
      monsters_url(:canvas => fb_canvas?)
    when 'property'
      properties_url(:canvas => fb_canvas?)
    when 'promotion'
      promotion = Promotion.find(story_data[:promotion_id])

      promotion_url(promotion, :canvas => fb_canvas?)
    when 'hit_listing_new', 'hit_listing_completed' # not used
      hit_listings_url(:canvas => fb_canvas?)
    when 'collection_completed'
      item_collections_url(:canvas => fb_canvas?)
    when 'collection_missing_items'
      give_inventories_url(
        :request_data => encryptor.encrypt(
          :items        => story_data[:items],
          :valid_till   => story_data[:valid_till],
          :character_id => story_data[:character_id]
        ),
        :canvas => fb_canvas?
      )
    when 'exchange'
      exchange = Exchange.find(story_data[:exchange_id])

      exchange_url(exchange.key, :canvas => fb_canvas?)
    when 'achievement'
      achievements_url(:canvas => fb_canvas?)
    when 'position_in_rating'
      rating_url(:canvas => fb_canvas?)
    else
      root_url(:canvas => fb_canvas?)
    end
  end
end
