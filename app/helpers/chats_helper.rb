module ChatsHelper
  def chat(chat_id)
    render('chats/chat', :chat_id => chat_id) if Setting.b(:chat_enabled)
  end
  
  def chat_dom_id(chat_id)
    Chat.key(chat_id)
  end
  
  def global_chat_key
    "global"
  end
  
  def global_chat
    if Setting[:global_chat_enabled]
      online_count = Chat.online_count(global_chat_key)
      
      link_to(online_count, chat_path, :id => 'global_chat_icon', 
        :title => t("chats.global.tooltip", :online_count => online_count)
      )
    end
  end
end