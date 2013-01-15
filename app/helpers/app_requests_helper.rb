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

  def accept_request_button(app_request, name)
    if app_request.acceptable?
      link_to(button(name), app_request_path(app_request),
        :remote => true,
        :method => :put,
        :'data-click-once' => true,
        :class => 'accept button'
      )
    else
      app_request.acceptance_error
    end
  end
end
