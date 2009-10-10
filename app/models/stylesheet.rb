class Stylesheet < ActiveRecord::Base
  DEFAULT_PATH = File.join(RAILS_ROOT, "app", "views", "stylesheets", "default.css")

  def use!
    self.class.transaction do
      self.class.update_all("current = NULL")

      self.update_attribute(:current, true)
    end
  end
end
