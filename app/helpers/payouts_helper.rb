module PayoutsHelper
  def payout_list(payouts, action, format = :result)
    return unless payouts

    returning result = "" do
      payouts.by_action(action).each do |payout|
        result << render("payouts/#{format}/#{payout.class.to_s.underscore.split("/").last}",
          :payout => payout
        )
      end
    end
  end
  safe_helper :payout_list

  def payout(type, value, options = {}, &block)
    result = content_tag(:div,
      content_tag(:span, options.delete(:label) || Character.human_attribute_name(type.to_s), :class => :label) +
      content_tag(:span, value, :class => :value) +
      (block_given? ? capture(&block) : ""),
      :class => "#{type} payout"
    )

    block_given? ? concat(result) : result
  end

  def payout_preview(type, value, options = {}, &block)
    result = content_tag(:div,
      content_tag(:span, value, :class => :value) +
      (block_given? ? capture(&block) : "") +
      content_tag(:span, options.delete(:label) || Character.human_attribute_name(type.to_s), :class => :label),
      :class => "#{type} payout"
    )

    block_given? ? concat(result) : result
  end
end