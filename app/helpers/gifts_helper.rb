module GiftsHelper

  # Render button, which shows facebook dialog for sending gift to another players
  def gift_send_button(item, options = {})
    options = options.deep_merge(
      :dialog => {
        :title    => t("app_requests.invites.gift.title", :item => item.name),
        :message  => t("app_requests.invites.gift.message", :item => item.name, :app => t('app_name')),
        :data     => {
          :item => item.alias
        }
      }
    )

    link_to_function(button(:send), invite_dialog(:gift, options),
      :class => "send button"
    )
  end

end
