module SerializeWithPreload
  def serialize(*args)
    Dir[File.join(Rails.root, "app", "models", "{effects,payouts,requirements}", "*.rb")].each do |file|
      file.gsub(File.join(Rails.root, "app", "models"), "").gsub(".rb", "").camelize.constantize
    end

    super(*args)
  end
end
