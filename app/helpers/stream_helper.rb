module StreamHelper
  def stream_dialog(options = {})
    "FB.Connect.streamPublish('', %s, %s, %s, %s, %s);" % [
      options[:attachment].reverse_merge(:media => default_stream_media).to_json,
      (options[:action_links] || default_stream_action_links).to_json,
      options[:target_id] || "null",
      options[:user_prompt] || "null",
      stream_callback_function(options)
    ]
  end
  safe_helper :stream_dialog

  def link_to_stream_dialog(title, options = {})
    link_to_function(title, stream_dialog(options), options.delete(:html) || {})
  end

  def default_stream_action_links(url = nil)
    [
      {
        :text => t("stories.default.action_link", :app => t("app_name")),
        :href => url || root_url(:canvas => true)
      }
    ]
  end

  def default_stream_media(url = nil)
    [
      {
        :type => "image",
        :src  => asset_image_path("logo_stream"),
        :href => url || root_url(:canvas => true)
      }
    ]
  end

  def stream_callback_function(options = {})
    "function(post_id, exception, data){ if(post_id != 'null'){#{options[:success]}} else {#{options[:failure]}}; }"
  end

  def character_level_up_stream_dialog
    stream_dialog(
      :attachment => {
        :name => t("stories.level_up.title", :level => current_character.level, :app => t("app_name")),
        :href => root_url(:canvas => true)
      }
    )
  end

  def fight_stream_dialog(fight)
    stream_dialog(
      :attachment => {
        :name => t("stories.fight.title", :level => fight.victim.level, :app => t("app_name")),
        :href => root_url(:canvas => true)
      }
    )
  end

  def inventory_stream_dialog(inventory)
    attachment = {
      :name => t("stories.inventory.title", :item => inventory.name, :app => t("app_name")),
      :href => item_group_items_url(inventory.item_group, :canvas => true)
    }

    if inventory.image?
      attachment[:media] = [
        {
          :type => "image",
          :src  => image_path(inventory.image.url),
          :href => item_group_items_url(inventory.item_group, :canvas => true)
        }
      ]
    end

    stream_dialog(:attachment => attachment)
  end

  def invitation_stream_dialog
    stream_dialog(
      :attachment => {
        :name         => t("stories.invitation.title", :app => t("app_name")),
        :href         => invitation_url(current_character.invitation_key, :reference => :invite_stream_name, :canvas => true),
        :description  => t("stories.invitation.description", :app => t("app_name")),
        
        :media => default_stream_media(
          invitation_url(current_character.invitation_key, :reference => :invite_stream_image, :canvas => true)
        )
      },
      :action_links => [
        {
          :text => t("stories.invitation.action_link"),
          :href => invitation_url(current_character.invitation_key, :reference => :invite_stream_link, :canvas => true)
        }
      ]
    )
  end

  def mission_complete_stream_dialog(mission)
    attachment = {
      :name => t("stories.mission.title", :mission => mission.name, :app => t("app_name")),
      :href => mission_group_url(mission.mission_group, :canvas => true)
    }

    if mission.image?
      attachment[:media] = [
        {
          :type => "image",
          :src  => image_path(mission.image.url),
          :href => mission_group_url(mission.mission_group, :canvas => true)
        }
      ]
    end

    stream_dialog(:attachment => attachment)
  end

  def boss_defeated_stream_dialog(boss)
    attachment = {
      :name => t("stories.boss.title", :boss => boss.name, :app => t("app_name")),
      :href => mission_group_url(boss.mission_group, :canvas => true)
    }

    if boss.image?
      attachment[:media] = [
        {
          :type => "image",
          :src  => image_path(boss.image.url),
          :href => mission_group_url(boss.mission_group, :canvas => true)
        }
      ]
    end

    stream_dialog(:attachment => attachment)
  end

  def help_request_stream_dialog(context)
    context_type = context.class.to_s.underscore

    help_url = help_request_url(current_character, :context => context_type, :canvas => true)

    case context
    when Fight
      attachment = {
        :name => t("stories.help_request.fight.title", :level => context.victim.level, :app => t("app_name")),
        :href => help_url
      }
    when Mission
      attachment = {
        :name         => t("stories.help_request.mission.title", :mission => context.name, :app => t("app_name")),
        :href         => help_url,
        :description  => t("stories.help_request.mission.description")
      }
    end

    stream_dialog(
      :attachment => attachment,
      :action_links => [
        {
          :text => t("stories.help_request.action_link"),
          :href => help_url
        }
      ],
      :success => "$.post('#{ help_requests_path(:context_id => context.id, :context_type => context_type) }')"
    )
  end

  def property_stream_dialog(property)
    attachment = {
      :name => t("stories.property.title", :property => property.name, :app => t("app_name")),
      :href => properties_url(:canvas => true)
    }

    if property.image?
      attachment[:media] = [
        {
          :type => "image",
          :src  => image_path(property.image.url),
          :href => properties_url(:canvas => true)
        }
      ]
    end

    stream_dialog(:attachment => attachment)
  end
end