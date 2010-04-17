require "digest/md5"

module FacebookMoney
  class << self
    def config
      @@config ||= YAML.load_file(File.join(RAILS_ROOT, "config", "facebook_money.yml"))

      return @@config[RAILS_ENV || "development"]
    end

    def provider
      @@provider ||= "FacebookMoney::#{ config["provider"].classify }".constantize
    end
  end

  module ControllerMethods
    def on_valid_facebook_money_request
      if FacebookMoney.provider.valid_request?(params)
        yield
        
        render FacebookMoney.provider.success_response
      else
        render FacebookMoney.provider.failure_response
      end
    end

    def facebook_money_user
      FacebookMoney.provider.user(params)
    end

    def facebook_money_amount
      FacebookMoney.provider.amount(params)
    end
  end

  module HelperMethods
    def facebook_money(options = {})
      FacebookMoney.provider.html_code(self, options)
    end
  end
end