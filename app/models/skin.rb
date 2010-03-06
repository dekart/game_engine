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

  after_save :generate_sass, :delete_compiled_stylesheet

  class << self
    def update_sass
      with_state(:active).first.try(:generate_sass)
    end
  end

  protected
  
  def generate_sass
    default_skin = File.read(Rails.root.join("public", "stylesheets", "sass", "application.sass"))

    default_skin.gsub!(/^\/\/\s*<--\s*Skin.*$/i, content)

    File.open(Rails.root.join("public", "stylesheets", "sass", "skins", "#{name.parameterize}.sass"), "w+") do |file|
      file << default_skin
    end
  end

  def delete_compiled_stylesheet
    stylesheet = Rails.root.join("public", "stylesheet", "skins", "#{name.parameterize}.css")

    FileUtils.rm(stylesheet) if File.file?(stylesheet)
  end
end
