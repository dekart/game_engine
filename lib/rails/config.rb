require 'settingslogic'

module Rails
  class Config < Settingslogic
    source "#{Rails.root}/config/settings.yml"
    namespace Rails.env
  end
  
  def self.restart!
    Rails.logger.debug "Restarting server..."

    FileUtils.mkdir_p Rails.root.join("tmp")

    FileUtils.touch Rails.root.join("tmp", "restart.txt")
  end
end