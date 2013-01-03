module GameData
  class Mission < Base
    class << self
      def load!
        Dir[Rails.root.join('db/data/missions/**/*.rb')].each do |file|
          eval File.read(file)
        end
      end
    end

    attr_reader :levels

    def initialize(key)
      super

      @levels = []
    end

    def group=(value)
      @group_id = value
    end

    def group
      GameData::MissionGroup[@group_id]
    end

    def level(&block)
      @levels << GameData::MissionLevel.define("#{ @key }_level_#{ @levels.size }", &block).tap{|l| l.mission = self }
    end

    def name
      I18n.t("data.missions.#{@key}.name")
    end

    def description
      I18n.t("data.missions.#{@key}.description", :default => '')
    end

    def button_label
      I18n.t("data.missions.#{@key}.button", :default => '')
    end

    def success_text
      I18n.t("data.missions.#{@key}.success", :default => '')
    end

    def failure_text
      I18n.t("data.missions.#{@key}.failure", :default => '')
    end

    def complete_text
      I18n.t("data.missions.#{@key}.complete", :default => '')
    end

    def as_json(*options)
      super.merge!(
        :name => name,
        :description => description,
        :button_label => button_label,
        :success_text => success_text,
        :failure_text => failure_text,
        :complete_text => complete_text,
        :pictures => pictures,
        :repeatable => tags.include?(:repeatable)
      ).reject!{|k, v| v.blank? }
    end

    def total_steps
      @total_steps ||= levels.sum{|l| l.steps }
    end

    def apply_reward_on(key, character, reward = nil)
      super(key, character, group.apply_reward_on(key, character, reward))
    end

    def preview_reward_on(key, character, reward = nil)
      super(key, character, group.preview_reward_on(key, character, reward))
    end

    def picture_formats
      %w{small}
    end

    def picture_path(format)
      "missions/#{ format }/#{ @key }.png"
    end
  end
end