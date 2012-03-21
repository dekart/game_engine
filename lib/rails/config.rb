require 'settingslogic'

module Rails
  class Config < Settingslogic
    source File.expand_path("../../../config/settings.yml", __FILE__)
    namespace Rails.env
  end

  def self.restart!
    Rails.logger.debug "Restarting server..."

    FileUtils.mkdir_p Rails.root.join("tmp")

    FileUtils.touch Rails.root.join("tmp", "restart.txt")
  end
end