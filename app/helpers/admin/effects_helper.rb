module Admin::EffectsHelper
  def admin_effects_preview(effects)
    result = ""

    effects.each do |effect|
      result << render("admin/effects/preview", :effect => effect)
    end

    result.html_safe
  end
end
