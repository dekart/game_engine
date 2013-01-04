module StreamHelper
  include FacebookHelper

  def stream_dialog(type, *args)
    options = args.extract_options!

    options = stream_dialog_options(type, *args).deep_merge(options)

    post_options = {
      :attachment   => options[:attachment],
      :action_links => options[:action_links]
    }

    success_event_track = ga_track_event('Stream Dialog', "#{ type.to_s.titleize } - Published")

    ''.tap do |result|
      result << ga_track_event('Stream Dialog', "#{ type.to_s.titleize } - Dialog").to_s
      result << options[:before].to_s
      result << %[
        StreamDialog.show(#{ post_options.to_json }, function(response){
          if(response){
            #{ success_event_track };
            #{ options[:success] };
          } else {
            #{ options[:failure] };
          }

          #{ options[:callback] };
        });
      ]

      result.gsub!(/\n\s+/, ' ')
    end.html_safe
  end

  def stream_dialog_options(type, *args)
    prepare_story(type, *(send("#{ type }_story_options", *args)))
  end

  protected

  def level_up_story_options
    [
      {
        :level => current_character.level
      },
      {
        :level => current_character.level
      }
    ]
  end


  def item_purchased_story_options(item)
    [
      item.attributes,
      {
        :item_id => item.id
      },
      (item.pictures.url(:stream) if item.pictures?)
    ]
  end


  def mission_help_story_options(mission)
    [
      mission.as_json,
      {
        :mission_id => mission.id
      },
      mission.pictures[:stream]
    ]
  end


  def mission_completed_story_options(mission)
    [
      mission.attributes,
      {
        :mission_id => mission.id
      },
      (mission.pictures.url(:stream) if mission.pictures?)
    ]
  end



  def monster_invite_story_options(monster)
    [
      monster.monster_type.attributes.merge(monster.attributes),
      {
        :monster_id => monster.id
      },
      (monster.pictures.url(:stream) if monster.pictures?)
    ]
  end


  def monster_defeated_story_options(monster)
    [
      monster.monster_type.attributes.merge(monster.attributes),
      {
        :monster_id => monster.id
      },
      (monster.pictures.url(:stream) if monster.pictures?)
    ]
  end


  def property_story_options(property)
    [
      property.property_type.attributes.merge(property.attributes),
      {
        :property_id => property.id
      },
      (property.pictures.url(:stream) if property.pictures?)
    ]
  end


  def promotion_story_options(promotion)
    [
      {
        :expires_at => l(promotion.valid_till, :format => :short)
      },
      {
        :promotion_id => promotion.id
      }
    ]
  end

  # not used
  def hit_listing_new_story_options(listing)
    [
      {
        :amount => listing.reward,
        :level  => listing.victim.level
      },
      {
        :hit_listing_id => listing.id
      }
    ]
  end

  # not used
  def hit_listing_completed_story_options(listing)
    [
      {
        :amount => listing.reward,
        :level  => listing.victim.level,
      },
      {
        :hit_listing_id => listing.id
      }
    ]
  end


  def collection_completed_story_options(collection)
    [
      collection.attributes,
      {
        :collection_id => collection.id
      }
    ]
  end


  def collection_missing_items_story_options(collection)
    missing_items = collection.missing_items(current_character)

    [
      collection.attributes.merge(
        :items => missing_items.collect{|i| i.name }.join(', ')
      ),
      {
        :collection_id  => collection.id,
        :items          => missing_items.collect{|i| i.id },
        :valid_till     => Setting.i(:collections_request_time).hours.from_now
      },
      (missing_items.first.pictures.url(:stream) if missing_items.first.pictures?)
    ]
  end

  def contest_finished_story_options(contest)
    [
      {
        :position => contest.position(current_character),
        :name => contest.name
      },
      {
        :position => contest.position(current_character),
        :name => contest.name
      },
      (contest.pictures.url(:stream) if contest.pictures?)
    ]
  end

  def exchange_story_options(exchange)
    [
      {
        :item_name => exchange.item.name,
        :amount => exchange.amount,
        :text => exchange.text
      },
      {
        :exchange_id => exchange.id
      },
      (exchange.item.pictures.url(:stream) if exchange.item.pictures?)
    ]
  end


  def achievement_story_options(type)
    [
      type.attributes,
      {
        :achievement_type_id => type.id
      },
      (type.pictures.url(:stream) if type.pictures?)
    ]
  end

  def position_in_rating_story_options(position, rating_name)
    [
      {
        :position => position,
        :rating_name => t("stories.position_in_rating.ratings.#{ rating_name }")
      },
      {},
      image_path("stream/rating.jpg")
    ]
  end


  def prepare_story(story_alias, interpolation_options = {}, story_data = {}, image = nil)
    interpolation_options.reverse_merge!(
      :player_name => current_character.user.first_name,
      :app => t("app_name")
    )

    interpolation_options = interpolation_options.symbolize_keys

    if story = Story.by_alias(story_alias).first
      image ||= story.pictures.url if story.pictures?

      name, description, action_link = story.interpolate([:title, :description, :action_link], interpolation_options)
    else
      story = story_alias

      name, description, action_link = I18n.t(["title", "description", "action_link"], {:scope => "stories.#{ story_alias }"}.merge(interpolation_options))
    end

    url = stream_url(story, "stream_#{ story_alias }", story_data)

    {
      :attachment => {
        :name => name,
        :description => description.to_s.html_safe,
        :href => url,
        :media => stream_image(image || :"stream_#{ story_alias }", url)
      },
      :action_links => stream_action_link(action_link, url)
    }
  end


  def stream_url(story, reference, data = {})
    story_url(story,
      :story_data => encryptor.encrypt(data.merge(:character_id => current_character.id)),
      :reference_code => reference_code(reference),
      :canvas => true
    )
  end


  def stream_action_link(text, url)
    [
      {
        :text => text.blank? ? t('stories.default.action_link', :app => t('app_name')) : text,
        :href => url
      }
    ]
  end


  def stream_image(image, url)
    src = view_context.image_path(image.is_a?(String) ? image : 'logo_stream.jpg')

    [
      {
        :type => "image",
        :src  => src,
        :href => url
      }
    ]
  end
end
