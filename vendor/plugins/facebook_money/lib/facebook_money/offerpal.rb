module FacebookMoney
  module Offerpal
    extend self
    
    def valid_request?(params)
      digest = Digest::MD5.hexdigest([params[:id], params[:snuid], params[:currency], FacebookMoney.config["secret"]].join(":"))

      digest == params[:verifier] && !user(params).nil?
    end

    def user(params)
      User.find_by_facebook_id(params[:snuid])
    end

    def amount(params)
      params[:currency].to_i
    end

    def html_code(template, options = {})
      default_options = {
        :src          => "http://pub.myofferpal.com/#{FacebookMoney.config["application_id"]}/showoffers.action?snuid=#{template.current_user.facebook_id}",
        :frameborder  => 0,
        :width        => 728,
        :height       => 2700,
        :scrolling    => :no
      }

      template.content_tag("iframe", "", default_options.merge(options))
    end

    def success_response
      {:text => "SUCCESS"}
    end

    def failure_response
      {:text => "ERROR", :status => 403}
    end
  end
end