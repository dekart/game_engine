module GiftsHelper
  
  # Render button, which shows facebook dialog for sending gift to another players
  def gift_send_button(item, options = {})
    options.reverse_merge!({
      :title => t("gifts.new.title"),
      :message => t("gifts.new.request.message", :item => item.name, :app => t('app_name'))
    })
    
    link_to_function(button(:send),
      fb_request_dialog(:gift,
        :title    => options[:title],
        :message  => options[:message],
        :data     => {
          :target_id => item.id,
          :target_type => Item.name
        },
        :params => {
          :target_id => item.id,
          :target_type => Item.name
        }
      ),
      :class => "send button"
    )
  end
  
end
