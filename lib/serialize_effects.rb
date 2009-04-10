module SerializeEffects
  def serialize_effects(field_name)
    Dir[File.join(RAILS_ROOT, "app", "models", "effects", "*")].each do |file|
      "Effects::#{File.basename(file, ".rb").classify}".constantize

      serialize field_name, Effects::Collection
    end
  end
end