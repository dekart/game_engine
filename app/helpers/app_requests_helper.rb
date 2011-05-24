module AppRequestsHelper
  def app_requests_counter
    amount = current_character.app_requests.visible.count
    
    if amount > 0
      link_to(amount, app_requests_path, 
        :id     => :app_requests_counter,
        :title  => t('app_requests.counter.text', :count => amount)
      )
    end
  end
end
