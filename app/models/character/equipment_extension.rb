module Character::EquipmentExtension

  def cache
    @cache = Rails.cache if @cache.nil?
    @cache
  end

  def effects
    @effects ||= cache.fetch(effect_cache_key, :expires_in => 15.minutes) do
      {}.tap do |effects|
        Item::EFFECTS.each do |effect|
          effects[effect] = inventories.sum{|i| i.send(effect) }
        end
      end
    end
    @effects
  end

  def effect(name)
    effects[name.to_sym]
  end

  def effect_cache_key
    "character_#{ character.id }_equipment_effects"
  end

  def clear_effect_cache!
    cache.delete(effect_cache_key)

    @effects = nil

    true
  end
end