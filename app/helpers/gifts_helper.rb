module GiftsHelper
  
  # Render button, which shows facebook dialog for sending gift to another players
  def gift_send_button(item, options = {})
    options.reverse_merge!(
      :title    => t("gifts.new.title"),
      :message  => t("gifts.new.request.message", :item => item.name, :app => t('app_name')),
      :data     => {
        :target_id => item.id,
        :target_type => Item.name
      },
      :exclude_ids => AppRequest::Gift.ids_to_exclude_for(current_character),
      :params => {
        :target_id => item.id,
        :target_type => Item.name
      }
    )
    
    link_to_function(button(:send), fb_request_dialog(:gift, options), 
      :class => "send button",
      :'data-click-once' => true
    )
  end
  
end
