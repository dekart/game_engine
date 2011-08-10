module AppRequestsHelper
  def app_requests_counter
    amount = Rails.cache.fetch(AppRequest::Base.cache_key(current_user), :expires_in => 10.minutes) do
      current_character.app_requests.visible.count
    end
    
    if amount > 0
      link_to(amount, app_requests_path, 
        :id     => :app_requests_counter,
        :title  => t('app_requests.counter.text', :count => amount)
      )
    end
  end
end
