module News
  class Base < ActiveRecord::Base
    set_table_name :news

    belongs_to :character
    serialize :data
  end
end
