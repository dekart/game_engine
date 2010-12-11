module StreamHelper
  def stream_dialog(options = {})
    attachment = options[:attachment]
    attachment[:media] ||= stream_image
    
    action_links  = options[:action_links] || default_stream_action_links

    result = "FB.ui(%s, %s);$(document).delay(100).queue(function(){ $(document).trigger('facebook.stream_publish') });" % [
      {
        :method       => 'stream.publish',
        :attachment   => attachment,
        :action_links => action_links
      }.to_json,
      stream_callback_function(options)
    ]

    result.html_safe
  end

  def stream_callback_function(options = {})
    "function(post_id, exception, data){ if(post_id != 'null'){%s;}else{%s;}; %s }" %[
      options[:success],
      options[:failure],
      options[:callback]
    ]
  end

  def default_stream_url(reference = nil)
    root_url(:reference_code => reference_code(reference), :canvas => true)
  end

  def default_stream_action_links(url = nil)
    [
      {
        :text => t("stories.default.action_link", :app => t("app_name")),
        :href => url || default_stream_url(:stream_default_link)
      }
    ]
  end

  def stream_image(options = {})
    if options[:image].is_a?(String)
      src = image_path(options[:image])
    elsif Asset[options[:image]]
      src = asset_image_path(options[:image])
    else
      src = asset_image_path('logo_stream')
    end

    href = options[:url].is_a?(String) ? options[:url] : default_stream_url(options[:url] || :stream_default_image)

    [
      {
        :type => "image",
        :src  => src,
        :href => href
      }
    ]
  end

  def character_level_up_stream_dialog(options = {})
    dialog_options = {
      :attachment => {
        :name => t("stories.level_up.title",
          :level  => current_character.level,
          :app    => t("app_name")
        ),
        :href => default_stream_url(:stream_level_up_name),
        :media => stream_image(
          :image  => :stream_level_up,
          :url    => :stream_level_up_image
        )
      }
    }

    dialog_options.reverse_merge!(options)

    stream_dialog(dialog_options)
  end

  def fight_stream_dialog(fight)
    stream_dialog(
      :attachment => {
        :name => t("stories.fight.title",
          :level  => fight.victim.level,
          :app    => t("app_name")
        ),
        :href => default_stream_url(:stream_fight_name),
        :media => stream_image(
          :image  => :stream_fight,
          :url    => :stream_fight_image
        )
      }
    )
  end

  def inventory_stream_dialog(inventory)
    attachment = {
      :name => t("stories.inventory.title",
        :item => inventory.name,
        :app  => t("app_name")
      ),
      :href => item_group_items_url(inventory.item_group,
        :canvas => true,
        :reference_code => reference_code(:stream_item_name)
      )
    }

    image_url = item_group_items_url(inventory.item_group,
      :canvas => true,
      :reference_code => reference_code(:stream_item_image)
    )

    attachment[:media] = stream_image(
      :image  => inventory.image? ? inventory.image.url(:stream) : :stream_item,
      :url    => image_url
    )

    stream_dialog(:attachment => attachment)
  end

  def mission_complete_stream_dialog(mission)
    attachment = {
      :name => t("stories.mission.title",
        :mission  => mission.name,
        :app      => t("app_name")
      ),
      :href => mission_group_url(mission.mission_group,
        :canvas => true,
        :reference_code => reference_code(:stream_mission_name)
      )
    }

    image_url = mission_group_url(mission.mission_group,
      :canvas => true,
      :reference_code => reference_code(:stream_mission_image)
    )

    attachment[:media] = stream_image(
      :image  => mission.image? ? mission.image.url(:stream) : :stream_mission_complete,
      :url    => image_url
    )

    stream_dialog(:attachment => attachment)
  end

  def boss_defeated_stream_dialog(boss)
    attachment = {
      :name => t("stories.boss.title",
        :boss => boss.name,
        :app  => t("app_name")
      ),
      :href => mission_group_url(boss.mission_group,
        :canvas => true,
        :reference_code => reference_code(:stream_boss_name)
      )
    }

    image_url = mission_group_url(boss.mission_group,
      :canvas => true,
      :reference_code => reference_code(:stream_boss_image)
    )

    attachment[:media] = stream_image(
      :image  => boss.image? ? boss.image.url(:stream) : :stream_boss,
      :url    => image_url
    )

    stream_dialog(:attachment => attachment)
  end

  def monster_defeated_stream_dialog(monster)
    attachment = {
      :name => t("stories.monster_defeated.title",
        :monster  => monster.name,
        :app      => t("app_name")
      ),
      :href => monster_url(monster,
        :canvas => true,
        :reference_code => reference_code(:stream_monster_defeated_name)
      )
    }

    image_url = monster_url(monster,
      :canvas => true,
      :reference_code => reference_code(:stream_monster_defeated_image)
    )

    attachment[:media] = stream_image(
      :image  => monster.image? ? monster.image.url(:stream) : :stream_monster_defeated,
      :url    => image_url
    )

    stream_dialog(:attachment => attachment)
  end

  def help_request_stream_dialog(context)
    context_type = context.class.to_s.underscore

    help_url = help_request_url(current_character,
      :canvas => true,
      :context => context_type,
      :reference_code => reference_code(:"stream_help_request_#{context_type}_name")
    )

    image_url = help_request_url(current_character,
      :canvas => true,
      :context => context_type,
      :reference_code => reference_code(:"stream_help_request_#{context_type}_image")
    )

    case context
    when Fight
      attachment = {
        :name => t("stories.help_request.fight.title",
          :level  => context.victim.level,
          :app    => t("app_name")
        ),
        :href => help_url,
        :media => stream_image(
          :image  => :stream_help_request_fight,
          :url    => image_url
        )
      }
    when Mission
      attachment = {
        :name         => t("stories.help_request.mission.title",
          :mission  => context.name,
          :app      => t("app_name")
        ),
        :href         => help_url,
        :description  => t("stories.help_request.mission.description")
      }

      attachment[:media] = stream_image(
        :image  => context.image? ? context.image.url(:stream) : :stream_help_request_mission,
        :url    => image_url
      )
    end

    stream_dialog(
      :attachment => attachment,
      :action_links => [
        {
          :text => t("stories.help_request.action_link"),
          :href => help_url
        }
      ],
      :success => "$.post('%s')" % help_requests_path(
        :context_id   => context.id,
        :context_type => context_type
      )
    )
  end

  def property_stream_dialog(property)
    attachment = {
      :name => t("stories.property.title",
        :property => property.name,
        :app      => t("app_name")
      ),
      :href => properties_url(
        :canvas => true,
        :reference_code => reference_code(:stream_property_name)
      )
    }

    image_url = properties_url(
      :canvas => true,
      :reference_code => reference_code(:stream_property_image)
    )

    attachment[:media] = stream_image(
      :image  => property.image? ? property.image.url(:stream) : :stream_propery,
      :url    => image_url
    )

    stream_dialog(:attachment => attachment)
  end

  def promotion_stream_dialog(promotion)
    attachment = {
      :name => t("stories.promotion.title", :app => t("app_name")),
      :href => promotion_url(promotion,
        :canvas => true,
        :reference_code => reference_code(:stream_promotion_name)
      ),

      :description => t("stories.promotion.description",
        :expires_at => l(promotion.valid_till, :format => :short)
      )
    }

    image_url = promotion_url(promotion,
      :canvas => true,
      :reference_code => reference_code(:stream_promotion_image)
    )

    attachment[:media] = stream_image(
      :image  => :stream_promotion,
      :url    => image_url
    )

    stream_dialog(
      :attachment => attachment,
      :action_links => [
        {
          :text => t("stories.promotion.action_link"),
          :href => promotion_url(promotion,
            :canvas => true,
            :reference_code => reference_code(:stream_promotion_link)
          )
        }
      ]
    )
  end

  def new_hit_listing_stream_dialog(listing)
    attachment = {
      :name => t("stories.hitlist.new_listing.title"),
      :href => hit_listings_url(
        :canvas => true,
        :reference_code => reference_code(:stream_hit_listing_new_name)
      ),

      :description => t("stories.hitlist.new_listing.description",
        :amount => listing.reward,
        :level  => listing.victim.level,
        :app    => t("app_name")
      )
    }

    image_url = hit_listings_url(
      :canvas => true,
      :reference_code => reference_code(:stream_hit_listing_new_image)
    )

    attachment[:media] = stream_image(
      :image  => :stream_hit_listing_new,
      :url    => image_url
    )

    stream_dialog(
      :attachment => attachment,
      :action_links => [
        {
          :text => t("stories.hitlist.new_listing.action_link"),
          :href => hit_listings_url(
            :canvas => true,
            :reference_code => reference_code(:stream_hit_listing_new_link)
          )
        }
      ]
    )
  end

  def completed_hit_listing_stream_dialog(listing)
    attachment = {
      :name => t("stories.hitlist.completed_listing.title"),
      :href => hit_listings_url(
        :canvas => true,
        :reference_code => reference_code(:stream_hit_listing_completed_name)
      ),

      :description => t("stories.hitlist.completed_listing.description",
        :amount => listing.reward,
        :level  => listing.victim.level,
        :app    => t("app_name")
      )
    }

    image_url = hit_listings_url(
      :canvas => true,
      :reference_code => reference_code(:stream_hit_listing_completed_image)
    )

    attachment[:media] = stream_image(
      :image  => :stream_hit_listing_completed,
      :url    => image_url
    )

    stream_dialog(
      :attachment => attachment,
      :action_links => [
        {
          :text => t("stories.hitlist.completed_listing.action_link"),
          :href => hit_listings_url(
            :canvas => true,
            :reference_code => reference_code(:stream_hit_listing_completed_link)
          )
        }
      ]
    )
  end

  def collection_stream_dialog(collection)
    attachment = {
      :name => t("stories.collection.title",
        :collection => collection.name,
        :app        => t("app_name")
      ),
      :href => item_collections_url(
        :canvas => true,
        :reference_code => reference_code(:stream_collection_name)
      )
    }

    image_url = item_collections_url(
      :canvas => true,
      :reference_code => reference_code(:stream_collection_image)
    )

    attachment[:media] = stream_image(
      :image  => :stream_collection,
      :url    => image_url
    )

    stream_dialog(:attachment => attachment)
  end
end
