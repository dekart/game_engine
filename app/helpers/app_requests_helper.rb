module AppRequestsHelper
  def app_requests_counter
    amount = current_character.app_requests.count

    if amount > 0
      link_to_function(amount, "AppRequestDialogController.show()",
        :id => :app_requests_counter,
        'data-tooltip-content' => t('app_requests.counter.text', :count => amount)
      )
    end
  end
end
