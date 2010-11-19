module PayoutsHelper
  def payout_list(payouts, action, options = {})
    return unless payouts

    options = options.reverse_merge(
      :format => :result
    )
    
    result = ""

    payouts.by_action(action).each do |payout|
      next if options[:format] == :preview && !payout.visible || options[:triggers] && (options[:triggers] & payout.apply_on).empty?

      result << render("payouts/#{options[:format]}/#{payout.class.payout_name}",
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
