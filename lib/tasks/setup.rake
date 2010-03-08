namespace :app do
  namespace :setup do
    desc "Setup Facebook application properties"
    task :facebook_app => :environment do
      admin = Facebooker::Session.create.admin

      admin.set_app_properties(
        :base_domain  => URI.parse(Facebooker.facebooker_config["callback_url"]).host,
        :canvas_name  => Facebooker.facebooker_config["canvas_page_name"],
        :callback_url => Facebooker.facebooker_config["callback_url"] + "/",
        :connect_url  => Facebooker.facebooker_config["callback_url"] + "/",
        
        :iframe_enable_util => 1
      )
    end
  end
end