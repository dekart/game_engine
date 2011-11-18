module HasEffects
  def has_effects
    preload_effects!

    serialize :effects, Effects::Collection

    send(:include, InstanceMethods)
  end
  
  def preload_effects!
    Dir[File.join(RAILS_ROOT, "app", "models", "effects", "*.rb")].each do |file|
      file.gsub(File.join(RAILS_ROOT, "app", "models"), "").gsub(".rb", "").classify.constantize
    end
  end

  module InstanceMethods
    def effects
      super || Effects::Collection.new
    end

    def effects=(collection)
      if collection && collection.empty?
        super(nil)
      else
        if collection and !collection.is_a?(Effects::Collection)
          items = collection.values.collect do |effect|
            effect.symbolize_keys!
            
            Effects::Base.by_name(effect[:type]).new(:value => effect[:value])
          end
        
          collection = Effects::Collection.new(*items)
        end
  
        super(collection)
      end
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
