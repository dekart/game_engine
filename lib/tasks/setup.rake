namespace :app do
  namespace :setup do
    desc "Setup application stylesheets"
    task :stylesheets => :environment do
      Asset.update_sass
      Skin.update_sass

      Sass::Plugin.update_stylesheets
    end

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

    desc "Re-import development assets. All existing assets will be destroyed!"
    task :import_assets, :destroy_old, :needs => :environment do |task, options|
      if options["destroy_old"] == "true"
        puts "Destroying existing assets..."

        Asset.destroy_all
      end

      require Rails.root.join("db", "seeds", "assets")

      Rake::Task["app:setup:stylesheets"].execute
    end

    desc "Re-import settings"
    task :reimport_settings => :environment do
      require Rails.root.join("db", "seeds", "settings")
    end
  end
end
