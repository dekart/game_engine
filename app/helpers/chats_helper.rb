module ChatsHelper
  def chat(chat_id)
    render('chats/chat', :chat_id => chat_id)
  end
  
  def chat_dom_id(chat_id)
    Chat.key(chat_id)
  end
end