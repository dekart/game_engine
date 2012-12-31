module GameData
  class MissionGroup < Base
    class << self
      def load!
        Dir[Rails.root.join('db/data/mission_groups.rb')].each do |file|
          eval File.read(file)
        end
      end
    end

    def visible?(character)
      super and (!tags.include?(:hide_unsatisfied) or requirements(character).satisfied?)
    end

    def missions
      @missions ||= GameData::Mission.select{|m| m.group == self }
    end

    def name
      I18n.t("data.mission_groups.#{@key}")
    end

    def as_json(*options)
      super.merge!(
        :name => name
      )
    end
  end
end