require "digest/md5"

module SuperRewards
  def self.config
    @@config ||= YAML.load_file(File.join(RAILS_ROOT, "config", "super_rewards.yml"))

    return @@config[RAILS_ENV || "development"]
  end

  module ControllerMethods
    def valid_super_rewards_request?
      digest = Digest::MD5.hexdigest([params[:id], params[:new], params[:uid], SuperRewards.config["secret"]].join(":"))
      
      return digest == params[:sig] && !super_rewards_user.nil?
    end

    def super_rewards_user
      User.find_by_facebook_id(params[:uid])
    end
  end

  module HelperMethods
    def fb_super_rewards_iframe(options = {})
      default_options = {
        :src          => "http://super.kitnmedia.com/super/offers?h=#{ SuperRewards.config["h"] }",
        :frameborder  => 0,
        :width        => 728,
        :height       => 2200,
        :scrolling    => :no
      }
      content_tag("fb:iframe", "", default_options.merge(options))
    end
  end
end

ActionController::Base.send(:include, SuperRewards::ControllerMethods)
ActionView::Base.send(:include, SuperRewards::HelperMethods)