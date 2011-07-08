module ChatsHelper
  def chat(chat_id)
    render('chats/chat', :chat_id => chat_id) if Setting.b(:chat_enabled)
  end
  
  def chat_dom_id(chat_id)
    Chat.key(chat_id)
  end
end