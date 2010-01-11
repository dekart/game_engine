require "digest/md5"

module FacebookMoney
  def self.config
    @@config ||= YAML.load_file(File.join(RAILS_ROOT, "config", "facebook_money.yml"))

    return @@config[RAILS_ENV || "development"]
  end

  def self.provider
    @@provider ||= "FacebookMoney::#{self.config["provider"].classify}".constantize
  end

  class SuperReward
    class << self
      def valid_request?(params)
        digest = Digest::MD5.hexdigest([params[:id], params[:new], params[:uid], FacebookMoney.config["secret"]].join(":"))

        return digest == params[:sig] && !user(params).nil?
      end

      def user(params)
        User.find_by_facebook_id(params[:uid])
      end

      def amount(params)
        params[:new].to_i
      end

      def html_code(template, options = {})
        default_options = {
          :src          => "http://www.superrewards-offers.com/super/offers?h=#{ FacebookMoney.config["key"] }",
          :frameborder  => 0,
          :width        => 728,
          :height       => 2700,
          :scrolling    => :no
        }

        template.content_tag("fb:iframe", "", default_options.merge(options))
      end

      def success_code
        "1"
      end

      def failure_code
        "0"
      end
    end
  end

  class Gambit
    class << self
      def valid_request?(params)
        digest = Digest::MD5.hexdigest([params[:uid], params[:amount], params[:time], params[:oid], FacebookMoney.config["secret"]].join(""))

        return digest == params[:sig] && !user(params).nil?
      end

      def user(params)
        User.find_by_facebook_id(params[:uid])
      end

      def amount(params)
        params[:amount].to_i
      end

      def html_code(template, options = {})
        default_options = {
          :src          => "http://getgambit.com/panel?k=#{ FacebookMoney.config["key"] }&uid=#{template.current_user.facebook_id}",
          :frameborder  => 0,
          :width        => 630,
          :height       => 1750
        }

        template.content_tag("fb:iframe", "", default_options.merge(options))
      end

      def success_code
        "OK"
      end

      def failure_code
        "ERROR:FATAL"
      end
    end
  end

  class Boomerang
    class << self
      def valid_request?(params)
        digest = Digest::MD5.hexdigest("uid=#{params[:uid]}currency=#{params[:currency]}type=#{params[:type]}ref=#{params[:ref]}#{FacebookMoney.config["secret"]}")

        Rails.logger.debug digest
        
        return digest == params[:sig] && !user(params).nil?
      end

      def user(params)
        User.find_by_facebook_id(params[:uid])
      end

      def amount(params)
        params[:currency].to_i
      end

      def html_code(template, options = {})
        default_options = {
          :src => "http://boomapi.com/api/?key=#{FacebookMoney.config["key"]}&uid=#{template.current_user.facebook_id}&widget=#{FacebookMoney.config["widget"] || "w1"}",
          :frameborder  => 0,
          :width        => 760,
          :height       => 1750
        }

        template.content_tag("fb:iframe", "", default_options.merge(options))
      end

      def success_code
        "OK"
      end

      def failure_code
        "ERROR"
      end
    end
  end

  module ControllerMethods
    def on_valid_facebook_money_request
      if FacebookMoney.provider.valid_request?(params)
        yield
        
        render :text => FacebookMoney.provider.success_code
      else
        render :text => FacebookMoney.provider.failure_code
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

ActionController::Base.send(:include, FacebookMoney::ControllerMethods)
ActionView::Base.send(:include, FacebookMoney::HelperMethods)