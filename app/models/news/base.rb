module News
  class Base < ActiveRecord::Base
    set_table_name :news

    belongs_to :character

    scope :latest, Proc.new{|limit|
      {
        :order => "id DESC",
        :limit => limit
      }
    }

    serialize :data

    def type_name
      self.class.name.split('::')[1].underscore
    end
  end
end
