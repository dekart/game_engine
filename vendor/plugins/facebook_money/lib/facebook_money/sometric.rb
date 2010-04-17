module FacebookMoney
  module Sometric
    extend self
    
    def valid_request?(params)
      digest = Digest::MD5.hexdigest("#{params[:uid]}#{params[:txn_value]}#{FacebookMoney.config["secret"]}#{params[:txn_date]}")

      digest == params[:txn_sig] && !user(params).nil?
    end

    def user(params)
      User.find_by_facebook_id(params[:uid])
    end

    def amount(params)
      params[:txn_value].to_i
    end

    def html_code(template, options = {})
      default_options = {
        :src => "http://v.sometrics.com/vc_delivery.html?zid=#{FacebookMoney.config["zid"]}&uid=#{template.current_user.facebook_id}&pid=#{FacebookMoney.config["pid"]}",
        :frameborder  => 0,
        :width        => 600,
        :height       => 2400
      }

      template.content_tag("iframe", "", default_options.merge(options))
    end

    def success_response
      {:text => "1"}
    end

    def failure_response
      {:text => "0"}
    end
  end
end