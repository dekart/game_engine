module HasInvisibility
  def invisible_types_ids=(values)
    values.each do |character_type_id, value|
      character_type = CharacterType.find character_type_id
      if value == '0' && invisible_types.include?(character_type)
        self.invisible_types.delete character_type
      elsif value == '1' && !invisible_types.include?(character_type)
        self.invisible_types << CharacterType.find(character_type_id)
      end
    end
  end

  def self.included mod
    mod.instance_eval do
      has_many :stuff_invisibilities, :as => :stuff, :dependent => :destroy
      has_many :invisible_types, :source => :character_type, :through => :stuff_invisibilities

      named_scope :available_for, Proc.new {|character|
        {
          :joins      => "LEFT JOIN stuff_invisibilities ON #{table_name}.id = stuff_invisibilities.stuff_id 
            AND stuff_invisibilities.character_type_id = #{character.character_type.id}
            AND stuff_invisibilities.stuff_type = \"#{class_name}\"", 
          :conditions => "stuff_invisibilities.id IS NULL"
        }
      }
    end
  end
end
