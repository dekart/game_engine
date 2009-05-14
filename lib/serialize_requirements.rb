module SerializeRequirements
  def serialize_requirements(field_name)
    Dir[File.join(RAILS_ROOT, "app", "models", "requirements", "*")].each do |file|
      "Requirements::#{File.basename(file, ".rb").classify}".constantize

      serialize field_name, Requirements::Collection
    end
  end
end