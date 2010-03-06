class Skin < ActiveRecord::Base
  state_machine :initial => :inactive do
    state :inactive
    state :active

    event :activate do
      transition :inactive => :active
    end

    event :deactivate do
      transition :active => :inactive
    end

    before_transition any => :active do
      Skin.with_state(:active).first.try(:deactivate)
    end
  end

  validates_presence_of :name
  validates_uniqueness_of :name

  after_save :regenerate_stylesheet

  class << self
    def update_sass
      with_state(:active).first.try(:generate_sass)
    end
  end

  protected

  def regenerate_stylesheet
    generate_sass

    Sass::Plugin.update_stylesheets
  end

  def generate_sass
    default_skin = File.read(Rails.root.join("public", "stylesheets", "sass", "application.sass"))

    default_skin.gsub!(/^\/\/\s*<--\s*Skin.*$/i, content)

    FileUtils.mkdir_p(File.dirname(sass_path))

    File.open(sass_path, "w+") do |file|
      file << default_skin
    end
  end

  def sass_path
    Rails.root.join("public", "stylesheets", "sass", "skins", "#{name.parameterize}.sass")
  end
end
