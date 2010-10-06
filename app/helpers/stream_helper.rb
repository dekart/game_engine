module StreamHelper
  def stream_dialog(options = {})
    attachment    = options[:attachment].reverse_merge(:media => default_stream_media)
    action_links  = options[:action_links] || default_stream_action_links
    target_id     = options[:target_id] || nil
    prompt_text   = options[:user_prompt] || nil

    result = "$(document).trigger('facebook.stream_publish');FB.Connect.streamPublish('', %s, %s, %s, %s, %s);" % [
      attachment.to_json,
      action_links.to_json,
      target_id.to_json,
      prompt_text.to_json,
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
    root_url(:canvas => true, :reference => reference, :referrer => current_user.id)
  end

  def default_stream_action_links(url = nil)
    [
      {
        :text => t("stories.default.action_link", :app => t("app_name")),
        :href => url || default_stream_url(:default_stream_link)
      }
    ]
  end

  def default_stream_media(url = nil)
    [
      {
        :type => "image",
        :src  => asset_image_path("logo_stream"),
        :href => url || default_stream_url(:default_stream_image)
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
        :href => default_stream_url(:level_up_stream_name)
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
        :href => default_stream_url(:fight_stream_name)
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
        :canvas     => true,
        :reference  => :item_stream_name,
        :referrer   => current_user.id
      )
    }

    if inventory.image?
      attachment[:media] = [
        {
          :type => "image",
          :src  => image_path(inventory.image.url),
          :href => item_group_items_url(inventory.item_group,
            :canvas     => true,
            :reference  => :item_stream_image,
            :referrer   => current_user.id
          )
        }
      ]
    end

    stream_dialog(:attachment => attachment)
  end

  def mission_complete_stream_dialog(mission)
    attachment = {
      :name => t("stories.mission.title", 
        :mission  => mission.name,
        :app      => t("app_name")
      ),
      :href => mission_group_url(mission.mission_group,
        :canvas     => true,
        :reference  => :mission_stream_name,
        :referrer   => current_user.id
      )
    }

    if mission.image?
      attachment[:media] = [
        {
          :type => "image",
          :src  => image_path(mission.image.url),
          :href => mission_group_url(mission.mission_group,
            :canvas     => true,
            :reference  => :mission_stream_image,
            :referrer   => current_user.id
          )
        }
      ]
    end

    stream_dialog(:attachment => attachment)
  end

  def boss_defeated_stream_dialog(boss)
    attachment = {
      :name => t("stories.boss.title",
        :boss => boss.name,
        :app  => t("app_name")
      ),
      :href => mission_group_url(boss.mission_group,
        :canvas     => true,
        :reference  => :boss_stream_name,
        :referrer   => current_user.id
      )
    }

    if boss.image?
      attachment[:media] = [
        {
          :type => "image",
          :src  => image_path(boss.image.url),
          :href => mission_group_url(boss.mission_group,
            :canvas     => true,
            :reference  => :boss_stream_image,
            :referrer   => current_user.id
          )
        }
      ]
    end

    stream_dialog(:attachment => attachment)
  end

  def help_request_stream_dialog(context)
    context_type = context.class.to_s.underscore

    help_url = help_request_url(current_character,
      :canvas     => true,
      :context    => context_type,
      :reference  => :help_stream,
      :referrer   => current_user.id
    )

    case context
    when Fight
      attachment = {
        :name => t("stories.help_request.fight.title", 
          :level  => context.victim.level,
          :app    => t("app_name")
        ),
        :href => help_url
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

      if context.image?
        attachment[:media] = [
          {
            :type => "image",
            :src  => image_path(context.image.url),
            :href => mission_group_url(context.mission_group,
              :canvas     => true,
              :reference  => :help_stream_image,
              :referrer   => current_user.id
            )
          }
        ]
      end
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
        :canvas     => true,
        :reference  => :property_stream_name,
        :referrer   => current_user.id
      )
    }

    if property.image?
      attachment[:media] = [
        {
          :type => "image",
          :src  => image_path(property.image.url),
          :href => properties_url(
            :canvas     => true,
            :reference  => :property_stream_image,
            :referrer   => current_user.id
          )
        }
      ]
    end

    stream_dialog(:attachment => attachment)
  end

  def promotion_stream_dialog(promotion)
    attachment = {
      :name => t("stories.promotion.title", :app => t("app_name")),
      :href => promotion_url(promotion,
        :canvas     => true,
        :reference  => :promotion_stream_name,
        :referrer   => current_user.id
      ),
      
      :description => t("stories.promotion.description", 
        :expires_at => l(promotion.valid_till, :format => :short)
      )
    }

    stream_dialog(
      :attachment => attachment,
      :action_links => [
        {
          :text => t("stories.promotion.action_link"),
          :href => promotion_url(promotion,
            :canvas     => true,
            :reference  => :promotion_stream_link,
            :referrer   => current_user.id
          )
        }
      ]
    )
  end

  def new_hit_listing_stream_dialog(listing)
    attachment = {
      :name => t("stories.hitlist.new_listing.title"),
      :href => hit_listings_url(
        :canvas     => true,
        :reference  => :new_hitlist_stream_name,
        :referrer   => current_user.id
      ),

      :description => t("stories.hitlist.new_listing.description",
        :amount => listing.reward,
        :level  => listing.victim.level,
        :app    => t("app_name")
      )
    }

    stream_dialog(
      :attachment => attachment,
      :action_links => [
        {
          :text => t("stories.hitlist.new_listing.action_link"),
          :href => hit_listings_url(
            :canvas     => true,
            :reference  => :new_hitlist_stream_link,
            :referrer   => current_user.id
          )
        }
      ]
    )
  end

  def completed_hit_listing_stream_dialog(listing)
    attachment = {
      :name => t("stories.hitlist.completed_listing.title"),
      :href => hit_listings_url(
        :canvas     => true,
        :reference  => :completed_hitlist_stream_name,
        :referrer   => current_user.id
      ),

      :description => t("stories.hitlist.completed_listing.description",
        :amount => listing.reward,
        :level  => listing.victim.level,
        :app    => t("app_name")
      )
    }

    stream_dialog(
      :attachment => attachment,
      :action_links => [
        {
          :text => t("stories.hitlist.completed_listing.action_link"),
          :href => hit_listings_url(
            :canvas     => true,
            :reference  => :completed_hitlist_stream_link,
            :referrer   => current_user.id
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
        :canvas     => true,
        :reference  => :collection_stream_name,
        :referrer   => current_user.id
      )
    }

    stream_dialog(:attachment => attachment)
  end
end