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
    image = nil
    
    interpolation_options = {
      :level  => current_character.level, 
      :app    => t('app_name')
    }
    
    if story = Story.by_alias(:level_up).first
      image ||= story.image.url if story.image?
      
      dialog_options = {
        :attachment => {
          :name         => story.interpolate(:title, interpolation_options),
          :description  => story.interpolate(:description, interpolation_options)
        },
        :action_links => stream_action_link(story.interpolate(:action_link, interpolation_options),
          :reference => :stream_level_up_link
        )
      }
    else
      dialog_options = {
        :attachment => {
          :name         => t("stories.level_up.title", interpolation_options),
          :description  => t("stories.level_up.description", interpolation_options)
        },
        :action_links => stream_action_link(t("stories.level_up.action_link", interpolation_options), 
          :reference => :stream_level_up_link
        )
      }
    end
    
    dialog_options.deep_merge!(
      :attachment => {
        :href => default_stream_url(:stream_level_up_name),
        :media => stream_image(
          :image  => image || :stream_level_up,
          :url    => :stream_level_up_image
        )
      }
    )
    dialog_options.deep_merge!(options)

    stream_dialog(dialog_options)
  end

  def inventory_stream_dialog(inventory)
    image = inventory.image.url(:stream) if inventory.image?

    interpolation_options = {
      :item => inventory.name, 
      :app  => t('app_name')
    }

    if story = Story.by_alias(:inventory).first      
      image ||= story.image.url if story.image?
      
      dialog_options = {
        :attachment => {
          :name         => story.interpolate(:title, interpolation_options),
          :description  => story.interpolate(:description, interpolation_options)
        },
        :action_links => stream_action_link(story.interpolate(:action_link, interpolation_options),
          :reference => :stream_item_link
        )
      }
    else
      dialog_options = {
        :attachment => {
          :name         => t("stories.inventory.title", interpolation_options),
          :description  => t("stories.inventory.description", interpolation_options)
        },
        :action_links => stream_action_link(t("stories.inventory.action_link", interpolation_options),
          :reference => :stream_item_link
        )
      }
    end
    
    dialog_options.deep_merge!(
      :attachment => {
        :href => item_group_items_url(inventory.item_group,
          :reference_code => reference_code(:stream_item_name),
          :canvas => true
        ),
        :media => stream_image(
          :image  => image || :stream_item,
          :url    => item_group_items_url(inventory.item_group,
            :reference_code => reference_code(:stream_item_image),
            :canvas => true
          )
        )
      }
    )
    
    stream_dialog(dialog_options)
  end

  def mission_complete_stream_dialog(mission)
    image = mission.image.url(:stream) if mission.image?

    interpolation_options = {
      :mission  => mission.name,
      :app      => t("app_name")
    }
    
    if story = Story.by_alias(:mission_complete).first
      image ||= story.image.url if story.image?
      
      dialog_options = {
        :attachment   => {
          :name         => story.interpolate(:title, interpolation_options),
          :description  => story.interpolate(:description, interpolation_options),
        },
        :action_links => stream_action_link(story.interpolate(:action_link, interpolation_options),
          :reference => :stream_mission_link
        )
      }
    else
      dialog_options = {
        :attachment   => {
          :name         => t("stories.mission.title", interpolation_options),
          :description  => t("stories.mission.description", interpolation_options),
        },
        :action_links => stream_action_link(t("stories.mission.action_link", interpolation_options),
          :reference => :stream_mission_link
        )
      }
    end
    
    dialog_options.deep_merge!(
      :attachment => {
        :href => mission_group_url(mission.mission_group,
          :reference_code => reference_code(:stream_mission_name),
          :canvas => true
        ),
        :media => stream_image(
          :image  => image || :stream_mission_complete,
          :url    => mission_group_url(mission.mission_group,
            :reference_code => reference_code(:stream_mission_image),
            :canvas => true
          )
        )
      }
    )

    stream_dialog(dialog_options)
  end

  def boss_defeated_stream_dialog(boss)
    image = boss.image.url(:stream) if boss.image?
    
    interpolation_options = {
      :boss => boss.name,
      :app  => t("app_name")
    }
    
    if story = Story.by_alias(:boss_defeated).first
      image ||= story.image.url if story.image?

      dialog_options = {
        :attachment   => {
          :name         => story.interpolate(:title, interpolation_options),
          :description  => story.interpolate(:description, interpolation_options),
        },
        :action_links => stream_action_link(story.interpolate(:action_link, interpolation_options),
          :reference => :stream_boss_link
        )
      }
    else
      dialog_options = {
        :attachment   => {
          :name         => t("stories.boss.title", interpolation_options),
          :description  => t("stories.boss.description", interpolation_options),
        },
        :action_links => stream_action_link(t("stories.boss.action_link", interpolation_options),
          :reference => :stream_boss_link
        )
      }
    end

    dialog_options.deep_merge!(
      :attachment => {
        :href => mission_group_url(boss.mission_group,
          :reference_code => reference_code(:stream_boss_name),
          :canvas => true
        ),
        :media => stream_image(
          :image  => image || :stream_boss,
          :url    => mission_group_url(boss.mission_group,
            :reference_code => reference_code(:stream_boss_image),
            :canvas => true
          )
        )
      }
    )

    stream_dialog(dialog_options)
  end

  def monster_invite_stream_dialog(monster)
    url_options = {
      :key    => encryptor.encrypt(monster.id),
      :canvas => true
    }
    
    action_url = monster_url(monster,
      url_options.merge(:reference_code => reference_code(:stream_monster_invite_link))
    )
    
    image = monster.image.url(:stream) if monster.image?
    
    interpolation_options = {
      :monster => monster.name,
      :app => t('app_name')
    }
    
    if story = Story.by_alias(:monster_invite).first
      image ||= story.image.url if story.image?

      dialog_options = {
        :attachment   => {
          :name         => story.interpolate(:title, interpolation_options),
          :description  => story.interpolate(:description, interpolation_options),
        },
        :action_links => stream_action_link(story.interpolate(:action_link, interpolation_options),
          :url  => action_url
        )
      }
    else
      dialog_options = {
        :attachment   => {
          :name         => t("stories.monster_invite.title", interpolation_options),
          :description  => t("stories.monster_invite.description", interpolation_options),
        },
        :action_links => stream_action_link(t("stories.monster_invite.action_link", interpolation_options),
          :url  => action_url
        )
      }
    end

    dialog_options.deep_merge!(
      :attachment => {
        :href => monster_url(monster,
          url_options.merge(:reference_code => reference_code(:stream_monster_invite_name))
        ),
        :media => stream_image(
          :image  => image || :stream_monster_invite,
          :url    => monster_url(monster,
            url_options.merge(:reference_code => reference_code(:stream_monster_invite_image))
          )
        )
      }
    )

    stream_dialog(dialog_options)
  end

  def monster_defeated_stream_dialog(monster)
    url_options = {
      :controller => 'monsters',
      :action     => 'show',
      :id         => encryptor.encrypt(monster.id),
      :canvas     => true
    }
    
    image = monster.image.url(:stream) if monster.image?
    
    interpolation_options = {
      :monster  => monster.name,
      :app      => t("app_name")
    }
    
    if story = Story.by_alias(:monster_defeated).first
      image ||= story.image.url if story.image?

      dialog_options = {
        :attachment   => {
          :name         => story.interpolate(:title, interpolation_options),
          :description  => story.interpolate(:description, interpolation_options),
        },
        :action_links => stream_action_link(story.interpolate(:action_link, interpolation_options),
          :reference => :stream_monster_defeated_link
        )
      }
    else
      dialog_options = {
        :attachment   => {
          :name         => t("stories.monster_defeated.title", interpolation_options),
          :description  => t("stories.monster_defeated.description", interpolation_options),
        },
        :action_links => stream_action_link(t("stories.monster_defeated.action_link", interpolation_options),
          :reference => :stream_monster_defeated_link
        )
      }
    end
    
    dialog_options.deep_merge!(
      :attachment => {
        :href => url_for(
          url_options.merge(:reference_code => reference_code(:stream_monster_defeated_name))
        ),
        :media => stream_image(
          :image  => image || :stream_monster_defeated,
          :url    => url_for(
            url_options.merge(:reference_code => reference_code(:stream_monster_defeated_image))
          )
        )
      }
    )

    stream_dialog(dialog_options)
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
    image = property.image.url(:stream) if property.image?
    
    interpolation_options = {
      :property => property.name,
      :app      => t("app_name")
    }
    
    if story = Story.by_alias(:property).first
      image ||= story.image.url if story.image?

      dialog_options = {
        :attachment   => {
          :name         => story.interpolate(:title, interpolation_options),
          :description  => story.interpolate(:description, interpolation_options),
        },
        :action_links => stream_action_link(story.interpolate(:action_link, interpolation_options),
          :reference => :stream_property_link
        )
      }
    else
      dialog_options = {
        :attachment   => {
          :name         => t("stories.property.title", interpolation_options),
          :description  => t("stories.property.description", interpolation_options),
        },
        :action_links => stream_action_link(t("stories.property.action_link", interpolation_options),
          :reference => :stream_property_link
        )
      }
    end
    
    dialog_options.deep_merge!(
      :attachment => {
        :href => properties_url(
          :reference_code => reference_code(:stream_property_name),
          :canvas => true
        ),
        :media => stream_image(
          :image => image || :stream_property,
          :url  => properties_url(
            :reference_code => reference_code(:stream_property_image),
            :canvas => true
          )
        )
      }
    )

    stream_dialog(dialog_options)
  end

  def promotion_stream_dialog(promotion)
    image = nil
    
    action_url = promotion_url(promotion,
      :reference_code => reference_code(:stream_promotion_link),
      :canvas => true
    )
    
    interpolation_options = {
      :expires_at => l(promotion.valid_till, :format => :short),
      :app => t("app_name")
    }
    
    if story = Story.by_alias(:promotion).first
      image ||= story.image.url if story.image?

      dialog_options = {
        :attachment   => {
          :name         => story.interpolate(:title, interpolation_options),
          :description  => story.interpolate(:description, interpolation_options),
        },
        :action_links => stream_action_link(story.interpolate(:action_link, interpolation_options),
          :url  => action_url
        )
      }
    else
      dialog_options = {
        :attachment   => {
          :name         => t("stories.promotion.title", interpolation_options),
          :description  => t("stories.promotion.description", interpolation_options),
        },
        :action_links => stream_action_link(t("stories.promotion.action_link", interpolation_options),
          :url => action_url
        )
      }
    end
    
    dialog_options.deep_merge!(
      :attachment => {
        :href => promotion_url(promotion,
          :reference_code => reference_code(:stream_promotion_name),
          :canvas => true
        ),
        :media => stream_image(
          :image  => image || :stream_promotion,
          :url    => promotion_url(promotion,
            :reference_code => reference_code(:stream_promotion_image),
            :canvas => true
          )
        )
      }
    )

    stream_dialog(dialog_options)
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

  def stream_action_link(*args)
    options = args.extract_options!
    text = args.first
    
    [
      {
        :text => text.blank? ? t("stories.default.action_link", :app => t("app_name")) : text,
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
