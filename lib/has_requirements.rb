module HasRequirements
  def has_requirements
    Dir[File.join(RAILS_ROOT, "app", "models", "requirements", "*.rb")].each do |file|
      file.gsub(File.join(RAILS_ROOT, "app", "models"), "").gsub(".rb", "").classify.constantize
    end

    serialize :requirements, Requirements::Collection

    send(:include, InstanceMethods)
  end

  module InstanceMethods
    def requirements
      super || Requirements::Collection.new
    end

    def requirements=(collection)
      if collection and !collection.is_a?(Requirements::Collection)
        items = collection.values.collect do |requirement|
          Requirements::Base.by_name(requirement[:type]).new(requirement)
        end

        collection = Requirements::Collection.new(*items)
      end

      super(collection)
    end
  end
end