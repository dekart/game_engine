module AppRequestsHelper
  def app_requests_counter
    amount = Rails.cache.fetch(AppRequest::Base.cache_key(current_user)) do
      current_character.app_requests.all.count
    end

    if amount > 0
      link_to_function(amount, "AppRequestDialogController.show()",
        :id => :app_requests_counter,
        'data-tooltip-content' => t('app_requests.counter.text', :count => amount)
      )
    end
  end
end
