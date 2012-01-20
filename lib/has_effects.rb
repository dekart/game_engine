module HasEffects
  def has_effects
    preload_effects!

    serialize :effects, Effects::Collection

    send(:include, InstanceMethods)
  end
  
  def preload_effects!
    Dir[File.join(Rails.root, "app", "models", "effects", "*.rb")].each do |file|
      file.gsub(File.join(Rails.root, "app", "models"), "").gsub(".rb", "").camelize.constantize
    end
  end

  module InstanceMethods
    def effects
      super || Effects::Collection.new
    end

    def effects=(collection)
      super(Effects::Collection.parse(collection))
    end
    
    def effects?
      effects.any?
    end
    
    # returns summary for additive (basic) effects, and a collection for complex effects
    def effect(name)
      if Effects::Base::BASIC_TYPES.include?(name.to_sym)
        effects.by_type(name).items.sum{|i| i.value }
      else
        effects.by_type(name)
      end
    end
  end
end
