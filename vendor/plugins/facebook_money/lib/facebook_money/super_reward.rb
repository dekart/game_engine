module FacebookMoney
  module SuperReward
    extend self
    
    def valid_request?(params)
      params[:sig] == Digest::MD5.hexdigest([params[:id], params[:new], params[:uid], FacebookMoney.config["secret"]].join(":"))
    end

    def user_id(params)
      params[:uid]
    end

    def amount(params)
      params[:new].to_i
    end

    def html_code(template, recipient_id, options = {})
      default_options = {
        :src          => "%s/super/offers?h=%s&uid=%s" % [
          template.request.ssl? ? 'https://secure2.kitnmedia.com' : 'http://www.superrewards-offers.com',
          FacebookMoney.config["key"],
          recipient_id
        ],
        :frameborder  => 0,
        :width        => 728,
        :height       => 2700,
        :scrolling    => :no
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