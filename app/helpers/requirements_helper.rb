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

    result = content_tag(:div, value.html_safe, :class => "requirement #{type} #{"not_satisfied" unless satisfied}")

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
      :amount => content_tag(:span, value, :class => :value),
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
  
  def refill_button_options(type, price)
    if current_character.vip_money >= price
      {
        :url    => premium_path(:type => type),
        :method => :put,
        :update => :result,
        :html   => {:class => "premium button"}
      }
      
    else
      {
        :url    => refill_dialog_premium_path(
          :type => type, 
          :vip_money => price
        ),
        :update => :ajax,
        :html   => {:class => "premium button"}
      }
    end
  end
end
