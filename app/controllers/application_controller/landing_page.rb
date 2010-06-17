class ApplicationController
  module LandingPage
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def landing_redirect(options = {})
        before_filter :check_landing_url, options
      end

      def skip_landing_redirect(options = {})
        skip_before_filter :check_landing_url, options
      end

      def landing_page(name, options = {})
        skip_landing_redirect(options)

        before_filter options do |controller|
          controller.send(:current_user).visit_landing!(name)
        end
      end
    end

    # Instance Methods
    
    protected

    def landing_url(last_landing)
      case last_landing.to_sym
      when :gifts
        invite_users_path
      else
        new_gift_path
      end
    end

    def check_landing_url
      if request.get? && current_user && current_user.should_visit_landing_page?
        redirect_to landing_url(current_user.last_landing)
      else
        true
      end
    end
  end
end