module FacebookMoney
  module Gambit
    extend self
    
    def valid_request?(params)
      digest = Digest::MD5.hexdigest([params[:uid], params[:amount], params[:time], params[:oid], FacebookMoney.config["secret"]].join(""))

      digest == params[:sig] && !user(params).nil?
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

      template.content_tag("iframe", "", default_options.merge(options))
    end

    def success_response
      {:text => "OK"}
    end

    def failure_response
      {:text => "ERROR:FATAL"}
    end
  end
end