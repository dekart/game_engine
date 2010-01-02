class Asset < ActiveRecord::Base
  has_attached_file :image, :styles => {:small => "100x100>"}

  validates_presence_of :alias
  validates_uniqueness_of "alias"

  after_save :touch_stylesheets
  after_destroy :touch_stylesheets

  class << self
    def [](value)
      find_by_alias(value.to_s)
    end
  end
  
  protected

  def touch_stylesheets
    FileUtils.touch(Stylesheet::DEFAULT_PATH)

    Stylesheet.update_all(["updated_at = ?", Time.now], ["current = ?", true])
  end
end
