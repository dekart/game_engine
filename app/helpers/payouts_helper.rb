module PayoutsHelper
  def payout_list(container, action)
    returning result = "" do
      container.payouts.by_action(action).each do |payout|
        result << render(
          :partial  => "payouts/#{payout.class.to_s.underscore.split("/").last}",
          :locals   => {:payout => payout}
        )
      end
    end
  end
end