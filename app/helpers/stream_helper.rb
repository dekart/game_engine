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

    result.html_safe!
  end

  def stream_callback_function(options = {})
    "function(post_id, exception, data){ if(post_id != 'null'){%s;}else{%s;} }" %[
      options[:success],
      options[:failure]
    ]
  end

  def default_stream_url(reference = nil)
    root_url(:canvas => true, :reference => reference)
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

  def character_level_up_stream_dialog
    stream_dialog(
      :attachment => {
        :name => t("stories.level_up.title", 
          :level  => current_character.level,
          :app    => t("app_name")
        ),
        :href => default_stream_url(:level_up_stream_name)
      }
    )
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
        :reference  => :item_stream_name,
        :canvas     => true
      )
    }

    if inventory.image?
      attachment[:media] = [
        {
          :type => "image",
          :src  => image_path(inventory.image.url),
          :href => item_group_items_url(inventory.item_group,
            :reference  => :item_stream_image,
            :canvas     => true
          )
        }
      ]
    end

    stream_dialog(:attachment => attachment)
  end

  def invitation_stream_dialog
    stream_dialog(
      :attachment => {
        :name         => t("stories.invitation.title", :app => t("app_name")),
        :href         => invitation_url(current_character.invitation_key, 
          :reference    => :invite_stream_name,
          :canvas       => true
        ),
        :description  => t("stories.invitation.description", :app => t("app_name")),
        
        :media => default_stream_media(
          invitation_url(current_character.invitation_key, 
            :reference  => :invite_stream_image,
            :canvas     => true
          )
        )
      },
      :action_links => [
        {
          :text => t("stories.invitation.action_link"),
          :href => invitation_url(current_character.invitation_key, 
            :reference  => :invite_stream_link,
            :canvas     => true
          )
        }
      ]
    )
  end

  def mission_complete_stream_dialog(mission)
    attachment = {
      :name => t("stories.mission.title", 
        :mission  => mission.name,
        :app      => t("app_name")
      ),
      :href => mission_group_url(mission.mission_group,
        :reference  => :mission_stream_name,
        :canvas     => true
      )
    }

    if mission.image?
      attachment[:media] = [
        {
          :type => "image",
          :src  => image_path(mission.image.url),
          :href => mission_group_url(mission.mission_group,
            :reference  => :mission_stream_image,
            :canvas     => true
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
        :reference  => :boss_stream_name,
        :canvas     => true
      )
    }

    if boss.image?
      attachment[:media] = [
        {
          :type => "image",
          :src  => image_path(boss.image.url),
          :href => mission_group_url(boss.mission_group,
            :reference  => :boss_stream_image,
            :canvas     => true
          )
        }
      ]
    end

    stream_dialog(:attachment => attachment)
  end

  def help_request_stream_dialog(context)
    context_type = context.class.to_s.underscore

    help_url = help_request_url(current_character,
      :context    => context_type,
      :reference  => :help_stream,
      :canvas     => true
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
              :reference  => :help_stream_image,
              :canvas     => true
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
        :reference  => :property_stream_name,
        :canvas     => true
      )
    }

    if property.image?
      attachment[:media] = [
        {
          :type => "image",
          :src  => image_path(property.image.url),
          :href => properties_url(
            :reference  => :property_stream_image,
            :canvas     => true
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
        :reference  => :promotion_stream_name,
        :canvas     => true
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
            :reference  => :promotion_stream_link,
            :canvas     => true
          )
        }
      ]
    )
  end
end