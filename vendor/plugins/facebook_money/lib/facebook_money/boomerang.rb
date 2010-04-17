module FacebookMoney
  module Boomerang
    extend self
    
    def valid_request?(params)
      digest = Digest::MD5.hexdigest("uid=#{params[:uid]}currency=#{params[:currency]}type=#{params[:type]}ref=#{params[:ref]}#{FacebookMoney.config["secret"]}")

      digest == params[:sig] && !user(params).nil?
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

      template.content_tag("iframe", "", default_options.merge(options))
    end

    def success_response
      {:text => "OK"}
    end

    def failure_response
      {:text => "ERROR"}
    end
  end
end