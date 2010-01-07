module RequirementsHelper
  def requirement_list(requirements, filter = nil)
    returning result = "" do
      requirements.each do |requirement|
        next if filter == :unsatisfied and requirement.satisfies?(current_character)

        result << render("requirements/#{requirement.name}",
          :requirement  => requirement,
          :satisfied    => requirement.satisfies?(current_character)
        )
      end
    end
  end
  safe_helper :requirement_list

  def requirement(*args, &block)
    type      = args.shift
    value     = block_given? ? capture(&block) : args.shift
    satisfied = args.first

    result = content_tag(:div, value, :class => "requirement #{type} #{"not_satisfied" unless satisfied}")

    block_given? ? concat(result) : result
  end

  def attribute_requirement(attribute, value, satisfied = true)
    requirement(attribute,
      t("requirements.attribute.text",
        :amount => content_tag(:span, value, :class => :value),
        :name   => Character.human_attribute_name(attribute.to_s)
      ),
      satisfied
    )
  end

  def vip_money_requirement(value)
    requirement(:vip_money,
      "%s (%s)" %[
        t("requirements.attribute.text",
          :amount => content_tag(:span, number_to_currency(value), :class => :value),
          :name   => Character.human_attribute_name("vip_money")
        ),
        link_to(fb_i(t("premia.get_vip")), premium_path)
      ],
      current_character.vip_money >= value
    )
  end
end