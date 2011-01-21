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


  def character_level_up_stream_dialog(options = {})
    interpolation_options = {
      :level  => current_character.level, 
      :app    => t('app_name')
    }
    
    if story = Story.by_alias(:level_up).first
      dialog_options = {
        :attachment => {
          :name         => story.interpolate(:title, interpolation_options),
          :description  => story.interpolate(:description, interpolation_options),
          
          :media => stream_image(
            :image  => story.image? ? story.image.url : :stream_level_up,
            :url    => :stream_level_up_image
          )
        },
        :action_links => stream_action_link(
          :text => story.interpolate(:action_link, interpolation_options),
          :reference => :stream_level_up_link
        )
      }
    else
      dialog_options = {
        :attachment => {
          :name         => t("stories.level_up.title", interpolation_options),
          :description  => t("stories.level_up.description", interpolation_options),
          
          :media => stream_image(
            :image  => :stream_level_up,
            :url    => :stream_level_up_image
          )
        },
        :action_links => stream_action_link(:reference => :stream_level_up_link)
      }
    end
    
    dialog_options.deep_merge!(
      :attachment => {
        :href => default_stream_url(:stream_level_up_name)
      }
    )
    dialog_options.deep_merge!(options)

    stream_dialog(dialog_options)
  end

  def inventory_stream_dialog(inventory)
    image_url = item_group_items_url(inventory.item_group,
      :canvas => true,
      :reference_code => reference_code(:stream_item_image)
    )
    
    interpolation_options = {
      :item => inventory.name, 
      :app  => t('app_name')
    }

    if story = Story.by_alias(:inventory).first      
      image = inventory.image.url(:stream) if inventory.image?
      image ||= story.image.url if story.image?
      
      dialog_options = {
        :attachment => {
          :name         => story.interpolate(:title, interpolation_options),
          :description  => story.interpolate(:description, interpolation_options),
          
          :media => stream_image(
            :image  => image || :stream_item,
            :url    => image_url
          )
        },
        :action_links => stream_action_link(
          :text => story.interpolate(:action_link, interpolation_options),
          :reference => :stream_level_up_link
        )
      }
    else
      dialog_options = {
        :attachment => {
          :name         => t("stories.inventory.title", interpolation_options),
          :description  => t("stories.inventory.description", interpolation_options),
          
          :media => stream_image(
            :image  => inventory.image? ? inventory.image.url(:stream) : :stream_item,
            :url    => image_url
          )
        },
        :action_links => stream_action_link(:reference => :stream_item_link)
      }
    end
    
    dialog_options.deep_merge!(
      :attachment => {
        :href => item_group_items_url(inventory.item_group,
          :reference_code => reference_code(:stream_item_name),
          :canvas => true
        )
      }
    )
    
    stream_dialog(dialog_options)
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

    stream_dialog(
      :attachment   => attachment,
      :action_links => stream_action_link(:reference => :stream_mission_link)
    )
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

    stream_dialog(
      :attachment   => attachment,
      :action_links => stream_action_link(:reference => :stream_boss_link)
    )
  end

  def monster_invite_stream_dialog(monster)
    url_options = {
      :key        => encryptor.encrypt(monster.id),
      :canvas     => true
    }

    attachment = {
      :name => t("stories.monster_invite.title",
        :monster  => monster.name,
        :app      => t("app_name")
      ),
      :description => t("stories.monster_invite.description",
        :monster  => monster.name,
        :app      => t("app_name")
      ),
      :href => monster_url(monster,
        url_options.merge(:reference_code => reference_code(:stream_monster_invite_name))
      )
    }

    attachment[:media] = stream_image(
      :image  => monster.image? ? monster.image.url(:stream) : :stream_monster_invite,
      :url    => monster_url(monster,
        url_options.merge(:reference_code => reference_code(:stream_monster_invite_image))
      )
    )

    stream_dialog(
      :attachment => attachment,
      :action_links => stream_action_link(
        :text => t("stories.monster_invite.action_link"),
        :url  => monster_url(monster,
          url_options.merge(:reference_code => reference_code(:stream_monster_invite_link))
        )
      )
    )
  end

  def monster_defeated_stream_dialog(monster)
    url_options = {
      :controller => 'monsters',
      :action     => 'show',
      :id         => encryptor.encrypt(monster.id),
      :canvas     => true
    }
    
    attachment = {
      :name => t("stories.monster_defeated.title",
        :monster  => monster.name,
        :app      => t("app_name")
      ),
      :href => url_for(
        url_options.merge(:reference_code => reference_code(:stream_monster_defeated_name))
      )
    }

    attachment[:media] = stream_image(
      :image  => monster.image? ? monster.image.url(:stream) : :stream_monster_defeated,
      :url    => url_for(
        url_options.merge(:reference_code => reference_code(:stream_monster_defeated_image))
      )
    )

    stream_dialog(
      :attachment   => attachment,
      :action_links => stream_action_link(:reference => :stream_monster_defeated_link)
    )
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
      :action_links => stream_action_link(
        :text => t("stories.help_request.action_link"),
        :url  => help_url
      ),
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

    stream_dialog(
      :attachment   => attachment,
      :action_links => stream_action_link(:reference => :stream_property_link)
    )
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
      :action_links => stream_action_link(
        :text => t("stories.promotion.action_link"),
        :url  => promotion_url(promotion,
          :canvas => true,
          :reference_code => reference_code(:stream_promotion_link)
        )
      )
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
      :action_links => stream_action_link(
        :text => t("stories.hitlist.new_listing.action_link"),
        :url  => hit_listings_url(
          :canvas => true,
          :reference_code => reference_code(:stream_hit_listing_new_link)
        )
      )
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
      :action_links => stream_action_link(
        :text => t("stories.hitlist.completed_listing.action_link"),
        :url  => hit_listings_url(
          :canvas => true,
          :reference_code => reference_code(:stream_hit_listing_completed_link)
        )
      )
    )
  end

  def collection_completed_stream_dialog(collection)
    attachment = {
      :name => t("stories.collection.completed.title",
        :collection => collection.name,
        :app        => t("app_name")
      ),
      :href => item_collections_url(
        :canvas => true,
        :reference_code => reference_code(:stream_collection_completed_name)
      )
    }

    image_url = item_collections_url(
      :canvas => true,
      :reference_code => reference_code(:stream_collection_completed_image)
    )

    attachment[:media] = stream_image(
      :image  => :stream_collection_completed,
      :url    => image_url
    )

    stream_dialog(
      :attachment => attachment,
      :action_links => stream_action_link(:reference => :stream_collection_completed_link)
    )
  end

  def collection_missing_items_stream_dialog(collection)
    missing_items = collection.missing_items(current_character)

    request_data = encryptor.encrypt(
      :items        => missing_items.collect{|i| i.id },
      :requester_id => current_character.id,
      :valid_till   => Setting.i(:collections_request_time).hours.from_now
    )

    attachment = {
      :name => t("stories.collection.missing_items.title", :app => t("app_name")),
      :description => t('stories.collection.missing_items.description',
        :collection => collection.name,
        :items      => missing_items.collect{|i| i.name }.join(', ')
      ),
      :href => give_inventories_url(
        :request_data   => request_data,
        :canvas         => true,
        :reference_code => reference_code(:stream_collection_missing_items_name)
      )
    }

    image_url = give_inventories_url(
      :request_data   => request_data,
      :canvas         => true,
      :reference_code => reference_code(:stream_collection_missing_items_image)
    )

    attachment[:media] = stream_image(
      :image  => :stream_collection_missing_items,
      :url    => image_url
    )

    stream_dialog(
      :attachment => attachment,
      :action_links => stream_action_link(
        :text => t("stories.collection.missing_items.action_link"),
        :url  => give_inventories_url(
          :request_data   => request_data,
          :canvas         => true,
          :reference_code => reference_code(:stream_collection_missing_items_link)
        )
      )
    )
  end
  
  protected
  
  def stream_callback_function(options = {})
    "function(post_id, exception, data){ if(post_id != 'null'){%s;}else{%s;}; %s }" % [
      options[:success],
      options[:failure],
      options[:callback]
    ]
  end

  def default_stream_url(reference = nil)
    root_url(:reference_code => reference_code(reference), :canvas => true)
  end

  def stream_action_link(options = {})
    [
      {
        :text => options[:text] || t("stories.default.action_link", :app => t("app_name")),
        :href => options[:url] || default_stream_url(options[:reference] || :stream_default_link)
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
  
end
