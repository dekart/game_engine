module PayoutsHelper
  def payout_list(payouts, action, format = :result)
    return unless payouts

    result = ""

    payouts.by_action(action).each do |payout|
      next if (format == :preview) && !payout.visible

      result << render("payouts/#{format}/#{payout.class.to_s.underscore.split("/").last}",
        :payout => payout
      )
    end

    result.html_safe
  end

  def payout(type, value, options = {}, &block)
    result = content_tag(:div,
      content_tag(:span, value, :class => :value) +
      (block_given? ? capture(&block) : "") +
      content_tag(:span, options.delete(:label) || Character.human_attribute_name(type.to_s), :class => :label),
      :class => "#{type} payout"
    )

    block_given? ? concat(result) : result
  end
end