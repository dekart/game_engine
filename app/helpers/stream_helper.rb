module StreamHelper
  def stream_dialog(options = {})
    "Facebook.streamPublish('', %s, %s, %s, %s, %s)" % [
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
        :caption => t("stories.level_up.title", :level => current_character.level, :app => t("app_name"))
      }
    )
  end

  def fight_stream_dialog(fight)
    stream_dialog(
      :attachment => {
        :caption => t("stories.fight.title", :level => fight.victim.level, :app => t("app_name"))
      }
    )
  end

  def inventory_stream_dialog(inventory)
    attachment = {
      :caption => t("stories.inventory.title", :item => inventory.name, :app => t("app_name"))
    }

    if inventory.image?
      attachment[:media] = [
        {
          :type => "image",
          :src  => image_path(inventory.image.url),
          :href => item_group_items_url(inventory.item_group)
        }
      ]
    end

    stream_dialog(:attachment => attachment)
  end

  def invitation_stream_dialog
    stream_dialog(
      :attachment => {
        :caption => t("stories.invitation.title", :app => t("app_name")),
        :description => t("stories.invitation.description", :app => t("app_name")),
        :media => default_stream_media(
          invitation_url(current_character.invitation_key, :reference => :invite_stream_image)
        )
      },
      :action_links => [
        {
          :text => t("stories.invitation.action_link"),
          :href => invitation_url(current_character.invitation_key, :reference => :invite_stream_link)
        }
      ]
    )
  end

  def mission_complete_stream_dialog(mission)
    attachment = {
      :caption => t("stories.mission.title", :mission => mission.name, :app => t("app_name"))
    }

    if mission.image?
      attachment[:media] = [
        {
          :type => "image",
          :src  => image_path(mission.image.url),
          :href => mission_groups_url
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
        :caption => t("stories.help_request.fight.title", :level => context.victim.level, :app => t("app_name"))
      }
    when Mission
      attachment = {
        :caption      => t("stories.help_request.mission.title", :mission => context.name, :app => t("app_name")),
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
      :success => "HelpRequest.create(#{context.id}, '#{context_type}')"
    )
  end

  def property_stream_dialog(property)
    attachment = {
      :caption => t("stories.property.title", :property => property.name, :app => t("app_name"))
    }

    if property.image?
      attachment[:media] = [
        {
          :type => "image",
          :src  => image_path(property.image.url),
          :href => new_property_url
        }
      ]
    end

    stream_dialog(:attachment => attachment)
  end
end