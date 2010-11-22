class Facebooker2Generator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  argument :application_type, :type => :string, :default => 'regular'

  def generate_facebooker2
    template  'facebooker.yml', 'config/facebooker.yml'
    copy_file 'initializer.rb', 'config/initializers/facebooker2.rb'

    if application_type == 'regular'
      puts <<-MSG
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        Add the following line to your app/controllers/application_controller.rb:

        include Facebooker2::Rails::Controller

        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      MSG
    else
      puts <<-MSG
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        Add the following lines to your app/controllers/application_controller.rb:

        include Facebooker2::Rails::Controller::CanvasOAuth

        ensure_canvas_connected_to_facebook :oauth_url, 'publish_stream'
        create_facebook_oauth_callback :oauth

        rescue_from Facebooker2::OAuthException do |exception|
          redirect_to 'http://www.facebook.com/'
        end

        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      MSG
    end
  end
end
