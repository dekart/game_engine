module RequirementsHelper
  def requirement_list(requirements, options = {})
    result = ""

    requirements.each do |requirement|
      next if options[:visible] && !requirement.visible

      result << render("requirements/#{requirement.name}",
        :requirement  => requirement,
        :satisfied    => requirement.satisfies?(current_character)
      )
    end

    result = result.html_safe

    block_given? && !result.blank? ? yield(result) : result
  end

  def requirement(*args, &block)
    type      = args.shift
    value     = block_given? ? capture(&block) : args.shift
    satisfied = args.first

    result = (
      '<div class="requirement %s %s">%s</div>' % [
        type,
        satisfied ? '' : 'not_satisfied',
        value
      ]
    ).html_safe

    block_given? ? concat(result) : result
  end

  def unsatisfied_requirement_list(requirements)
    result = ""

    requirements.each do |requirement|
      next if requirement.satisfies?(current_character)

      result << render("requirements/not_satisfied/#{requirement.name}",
        :requirement  => requirement
      )
    end

    result.html_safe
  end
  
  def unsatisfied_requirement_first(requirements)
    result = ""
    
    requirements.each do |requirement|
      unless requirement.satisfies?(current_character)
        result = render("requirements/not_satisfied/#{requirement.name}",
          :requirement  => requirement
        )
        break
      end
    end
    
    result.html_safe
  end

  def attribute_requirement_text(attribute, value)
    t("requirements.attribute.text",
      :amount => span_tag(value, :value),
      :name   => Character.human_attribute_name(attribute.to_s)
    ).html_safe
  end

  def attribute_requirement(attribute, value, satisfied = true)
    requirement(attribute, attribute_requirement_text(attribute, value), satisfied)
  end

  def vip_money_requirement(value, additional_text = nil)
    requirement_text = attribute_requirement_text(:vip_money, number_to_currency(value))
    
    if current_character.vip_money < value
      requirement_text = "%s (%s)" % [requirement_text, link_to(t("premia.get_vip"), premium_path(:anchor => :buy))]
    end
    
    requirement(:vip_money, "#{ requirement_text } #{additional_text}", current_character.vip_money >= value)
  end

  def refill_button(type)
    price = Setting.i(:"premium_#{type}_price")

    if current_character.vip_money >= price
      link_to_remote(
        button( :refill, :price => span_tag(price, :amount)),
        :url    => premium_path(:type => :"refill_#{type}"),
        :method => :put,
        :update => :result,
        :html   => {:class => "premium button"}
      )

    else
      link_to_remote(
        button( :refill, :price => span_tag(price, :amount)),
        :url    => refill_dialog_premium_path(
          :type => :"refill_#{type}",
          :vip_money => price
        ),
        :update => :ajax,
        :html   => {:class => "premium button"}
      )
    end
  end

end
