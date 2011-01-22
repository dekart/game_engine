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


  def level_up_stream_dialog(options = {})
    image = nil
    
    interpolation_options = {
      :level  => current_character.level, 
      :app    => t('app_name')
    }
    
    if story = Story.by_alias(:level_up).first
      image = story.image.url if story.image?
      
      name, description, action_link = story.interpolate([:title, :description, :action_link], interpolation_options)
    else
      story = :level_up
      
      name, description, action_link = I18n.t(["title", "description", "action_link"], {:scope => 'stories.level_up'}.merge(interpolation_options))
    end
    
    dialog_options = {
      :attachment => {
        :name         => name,
        :description  => description,
        :href => stream_url(story, :stream_level_up_name),
        :media => stream_image(
          :image  => image || :stream_level_up,
          :url    => stream_url(story, :stream_level_up_image)
        )
      },
      :action_links => stream_action_link(action_link,
        :url => stream_url(story, :stream_level_up_link)
      )
    }
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
      image = story.image.url if story.image?
      
      name, description, action_link = story.interpolate([:title, :description, :action_link], interpolation_options)
    else
      story = :inventory
      
      name, description, action_link = I18n.t(["title", "description", "action_link"], {:scope => 'stories.inventory'}.merge(interpolation_options))
    end
    
    dialog_options = {
      :attachment => {
        :name         => name,
        :description  => description,
        :href => stream_url(story, :stream_inventory_name, :item_group_id => inventory.item_group),
        :media => stream_image(
          :image  => image || :stream_inventory,
          :url    => stream_url(story, :stream_inventory_image, :item_group_id => inventory.item_group)
        )
      },
      :action_links => stream_action_link(action_link,
        :url => stream_url(story, :stream_inventory_link)
      )
    }
    
    stream_dialog(dialog_options)
  end

  def mission_complete_stream_dialog(mission)
    image = mission.image.url(:stream) if mission.image?

    interpolation_options = {
      :mission  => mission.name,
      :app      => t("app_name")
    }
    
    if story = Story.by_alias(:mission).first
      image = story.image.url if story.image?
      
      name, description, action_link = story.interpolate([:title, :description, :action_link], interpolation_options)
    else
      story = :mission
      
      name, description, action_link = I18n.t(["title", "description", "action_link"], {:scope => 'stories.mission'}.merge(interpolation_options))
    end
    
    dialog_options = {
      :attachment => {
        :name => name,
        :description => description,
        :href => stream_url(story, :stream_mission_name, :mission_group_id => mission.mission_group),
        :media => stream_image(
          :image  => image || :stream_mission_complete,
          :url    => stream_url(story, :stream_mission_image, :mission_group_id => mission.mission_group)
        )
      },
      :action_links => stream_action_link(action_link,
        :url => stream_url(story, :stream_mission_link, :mission_group_id => mission.mission_group)
      )
    }

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
      
      name, description, action_link = story.interpolate([:title, :description, :action_link], interpolation_options)
    else
      story = :boss

      name, description, action_link = I18n.t(["title", "description", "action_link"], {:scope => 'stories.boss'}.merge(interpolation_options))
    end
    
    dialog_options = {
      :attachment => {
        :name => name,
        :description => description,
        :href => stream_url(story, :stream_boss_name, :mission_group_id => boss.mission_group),
        :media => stream_image(
          :image  => image || :stream_boss,
          :url    => stream_url(story, :stream_boss_image, :mission_group_id => boss.mission_group)
        )
      },
      :action_links => stream_action_link(action_link,
        :url => stream_url(story, :stream_boss_link, :mission_group_id => boss.mission_group)
      )
    }

    stream_dialog(dialog_options)
  end

  def monster_invite_stream_dialog(monster)
    image = monster.image.url(:stream) if monster.image?
    
    interpolation_options = {
      :monster => monster.name,
      :app => t('app_name')
    }
    
    if story = Story.by_alias(:monster_invite).first
      image ||= story.image.url if story.image?
      
      name, description, action_link = story.interpolate([:title, :description, :action_link], interpolation_options)
    else
      story = :monster_invite

      name, description, action_link = I18n.t(["title", "description", "action_link"], {:scope => 'stories.monster_invite'}.merge(interpolation_options))
    end

    monster_key = encryptor.encrypt(monster.id)
    
    dialog_options = {
      :attachment => {
        :name => name,
        :description => description,
        :href => stream_url(story, :stream_monster_invite_name, :monster_key => monster_key),
        :media => stream_image(
          :image  => image || :stream_monster_invite,
          :url    => stream_url(story, :stream_monster_invite_image, :monster_key => monster_key)
        )
      },
      :action_links => stream_action_link(action_link,
        :url => stream_url(story, :stream_monster_invite_link, :monster_key => monster_key)
      )
    }

    stream_dialog(dialog_options)
  end

  def monster_defeated_stream_dialog(monster)
    image = monster.image.url(:stream) if monster.image?
    
    interpolation_options = {
      :monster  => monster.name,
      :app      => t("app_name")
    }
    
    if story = Story.by_alias(:monster_defeated).first
      image ||= story.image.url if story.image?
      
      name, description, action_link = story.interpolate([:title, :description, :action_link], interpolation_options)
    else
      story = :monster_defeated

      name, description, action_link = I18n.t(["title", "description", "action_link"], {:scope => 'stories.monster_defeated'}.merge(interpolation_options))
    end
    
    monster_key = encryptor.encrypt(monster.id)
    
    dialog_options = {
      :attachment => {
        :name => name,
        :description => description,
        :href => stream_url(story, :stream_monster_defeated_name, :monster_key => monster_key),
        :media => stream_image(
          :image  => image || :stream_monster_defeated,
          :url    => stream_url(story, :stream_monster_defeated_image, :monster_key => monster_key)
        )
      },
      :action_links => stream_action_link(action_link,
        :url => stream_url(story, :stream_monster_defeated_link, :monster_key => monster_key)
      )
    }

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
      
      name, description, action_link = story.interpolate([:title, :description, :action_link], interpolation_options)
    else
      story = :property

      name, description, action_link = I18n.t(["title", "description", "action_link"], {:scope => 'stories.property'}.merge(interpolation_options))
    end
    
    dialog_options = {
      :attachment => {
        :name => name,
        :description => description,
        :href => stream_url(story, :stream_property_name),
        :media => stream_image(
          :image => image || :stream_property,
          :url  => stream_url(story, :stream_property_image)
        )
      },
      :action_links => stream_action_link(action_link,
        :url => stream_url(story, :stream_property_link)
      )
    }

    stream_dialog(dialog_options)
  end

  def promotion_stream_dialog(promotion)
    image = nil
    
    interpolation_options = {
      :expires_at => l(promotion.valid_till, :format => :short),
      :app => t("app_name")
    }
    
    if story = Story.by_alias(:promotion).first
      image ||= story.image.url if story.image?
      
      name, description, action_link = story.interpolate([:title, :description, :action_link], interpolation_options)
    else
      story = :promotion

      name, description, action_link = I18n.t(["title", "description", "action_link"], {:scope => 'stories.promotion'}.merge(interpolation_options))
    end

    dialog_options = {
      :attachment => {
        :name => name,
        :description => description,
        :href => stream_url(story, :stream_promotion_name, :promotion_id => promotion),
        :media => stream_image(
          :image  => image || :stream_promotion,
          :url    => stream_url(story, :stream_promotion_image, :promotion_id => promotion)
        )
      },
      :action_links => stream_action_link(action_link,
        :url  => stream_url(story, :stream_promotion_link, :promotion_id => promotion)
      )
    }

    stream_dialog(dialog_options)
  end

  def new_hit_listing_stream_dialog(listing)
    image = nil
    
    interpolation_options = {
      :amount => listing.reward,
      :level  => listing.victim.level,
      :app => t("app_name")
    }
    
    if story = Story.by_alias(:hit_listing_new).first
      image ||= story.image.url if story.image?
      
      name, description, action_link = story.interpolate([:title, :description, :action_link], interpolation_options)
    else
      story = :hit_listing_new

      name, description, action_link = I18n.t(["title", "description", "action_link"], {:scope => 'stories.hitlist.new_listing'}.merge(interpolation_options))
    end

    dialog_options = {
      :attachment => {
        :name => name,
        :description => description,
        :href => stream_url(story, :stream_hit_listing_new_name),
        :media => stream_image(
          :image  => image || :stream_hit_listing_new,
          :url    => stream_url(story, :stream_hit_listing_new_image)
        )
      },
      :action_links => stream_action_link(action_link,
        :url  => stream_url(story, :stream_hit_listing_new_link)
      )
    }

    stream_dialog(dialog_options)
  end

  def completed_hit_listing_stream_dialog(listing)
    image = nil
    
    interpolation_options = {
      :amount => listing.reward,
      :level  => listing.victim.level,
      :app => t("app_name")
    }
    
    if story = Story.by_alias(:hit_listing_completed).first
      image ||= story.image.url if story.image?
      
      name, description, action_link = story.interpolate([:title, :description, :action_link], interpolation_options)
    else
      story = :hit_listing_completed

      name, description, action_link = I18n.t(["title", "description", "action_link"], {:scope => 'stories.hitlist.completed_listing'}.merge(interpolation_options))
    end

    dialog_options = {
      :attachment => {
        :name => name,
        :description => description,
        :href => stream_url(story, :stream_hit_listing_completed_name),
        :media => stream_image(
          :image  => image || :stream_hit_listing_completed,
          :url    => stream_url(story, :stream_hit_listing_completed_image)
        )
      },
      :action_links => stream_action_link(action_link,
        :url  => stream_url(story, :stream_hit_listing_completed_link)
      )
    }

    stream_dialog(dialog_options)
  end

  def collection_completed_stream_dialog(collection)
    image = nil
    
    interpolation_options = {
      :collection => collection.name,
      :app => t("app_name")
    }
    
    if story = Story.by_alias(:collection_completed).first
      image ||= story.image.url if story.image?
      
      name, description, action_link = story.interpolate([:title, :description, :action_link], interpolation_options)
    else
      story = :collection_completed

      name, description, action_link = I18n.t(["title", "description", "action_link"], {:scope => 'stories.collection.completed'}.merge(interpolation_options))
    end

    dialog_options = {
      :attachment => {
        :name => name,
        :description => description,
        :href => stream_url(story, :stream_collection_completed_name),
        :media => stream_image(
          :image  => image || :stream_collection_completed,
          :url    => stream_url(story, :stream_collection_completed_image)
        )
      },
      :action_links => stream_action_link(action_link,
        :url  => stream_url(story, :stream_collection_completed_link)
      )
    }

    stream_dialog(dialog_options)
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
  
  def stream_url(story, reference, url_options = {})
    story_url(story,
      url_options.reverse_merge(
        :reference_code => reference_code(reference),
        :canvas => true
      )
    )
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
