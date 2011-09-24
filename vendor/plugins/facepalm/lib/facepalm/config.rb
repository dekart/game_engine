module Facepalm
  class Config
    attr_accessor :config
    
    class << self
      def default
        @@default_config ||= self.new(load_config_from_file)
      end

      def load_config_from_file
        config_data = YAML.load(
          ERB.new(
            File.read(::Rails.root.join("config", "facepalm.yml"))
          ).result
        )[::Rails.env]

        raise NotConfigured.new("Unable to load configuration for #{ ::Rails.env } from config/facepalm.yml. Is it set up?") if config_data.nil?

        config_data
      end
    end
    
    def initialize(options = {})
      self.config = options.to_options
    end
    
    %w{app_id secret canvas_page_name callback_domain}.each do |attribute|
      class_eval %{
        def #{ attribute }
          config[:#{ attribute }]
        end
      }
    end
    
    def oauth_client
      @oauth_client ||= Koala::Facebook::OAuth.new(app_id, secret)
    end
    
    def canvas_page_url(protocol)
      "#{ protocol }apps.facebook.com/#{ canvas_page_name }"
    end
    
    def callback_url(protocol)
      protocol + callback_domain
    end
  end
end