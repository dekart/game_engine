module PayoutsHelper
  def payout_list(payouts, action)
    returning result = "" do
      payouts.by_action(action).each do |payout|
        result << render(
          :partial  => "payouts/#{payout.class.to_s.underscore.split("/").last}",
          :locals   => {:payout => payout}
        )
      end
    end
  end

  def payout(type, label, value, &block)
    result = content_tag(:div,
      content_tag(:span, label, :class => :label) +
      content_tag(:span, value, :class => :value) +
      (block_given? ? capture(&block) : ""),
      :class => "#{type} payout"
    )

    block_given? ? concat(result) : result
  end

  safe_helper :payout_list
end