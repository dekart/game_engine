module PayoutsHelper
  class ListBuilder
    attr_reader :template, :container, :payouts, :options

    delegate :capture, :render, :to => :template

    def initialize(template, container, payouts, options = {})
      @template = template
      @container = container
      @payouts = payouts
      @options = options.reverse_merge(
        :action => :add,
        :format => :result
      )
    end

    def applicable_payouts
      @applicable_payouts ||= payouts.by_action(options[:action]).reject{|payout|
        options[:format] == :preview && !payout.visible ||
        options[:triggers] && (options[:triggers] & payout.apply_on).empty?
      }
    end

    def payout_list
      result = ""

      applicable_payouts.each do |payout|
        result << render("payouts/#{options[:format]}/#{payout.class.payout_name}",
            :container  => container,
            :payout     => payout,
            :options    => options
          )
      end

      result.html_safe
    end

    def html(&block)
      if applicable_payouts.any?
        block_given? ? capture(self, &block) : payout_list
      end
    end
  end

  def payout_list(container, payouts, options = {}, &block)
    return if payouts.nil? || payouts.empty?

    content = ListBuilder.new(self, container, payouts, options).html(&block)

    block_given? ? concat(content.to_s) : content.to_s
  end

  def payout(type, value, options = {}, &block)
    label = options[:label] || Character.human_attribute_name(type.to_s)

    result = (
      %{
        <div class="#{ type } payout">
          <span class="value">#{ value }</span>
          #{ capture(&block) if block_given? }
          <span class="label">#{ label }</span>
        </div>
      }
    ).html_safe

    block_given? ? concat(result) : result
  end

  def payout_item_label(payout)
    name = span_tag(payout.item.name, :name)

    (
      payout.amount > 1 ? t("payouts.item.label", :name => name, :amount => payout.amount) : name
    ).html_safe
  end
end
