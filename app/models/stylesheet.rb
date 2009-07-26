class Stylesheet < ActiveRecord::Base
  def use!
    self.class.transaction do
      self.class.update_all("current = NULL")

      self.update_attribute(:current, true)
    end
  end
end
