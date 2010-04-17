module FacebookMoney
  module SuperReward
    extend self
    
    def valid_request?(params)
      digest = Digest::MD5.hexdigest([params[:id], params[:new], params[:uid], FacebookMoney.config["secret"]].join(":"))

      digest == params[:sig] && !user(params).nil?
    end

    def user(params)
      User.find_by_facebook_id(params[:uid])
    end

    def amount(params)
      params[:new].to_i
    end

    def html_code(template, options = {})
      default_options = {
        :src          => "http://www.superrewards-offers.com/super/offers?h=#{ FacebookMoney.config["key"] }&uid=#{template.current_user.facebook_id}",
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