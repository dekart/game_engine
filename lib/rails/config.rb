require 'settingslogic'

module Rails
  class Config < Settingslogic
    source "#{Rails.root}/config/settings.yml"
    namespace Rails.env
  end
end