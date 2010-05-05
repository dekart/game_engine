module HasInvisibility
  def itypes_ids=(values)
    values.each do |ctype_id, value|
      ctype = CharacterType.find ctype_id
      if value == '0' && itypes.include?(ctype)
        self.itypes.delete ctype
      elsif value == '1' && !itypes.include?(ctype)
        self.itypes << CharacterType.find(ctype_id)
      end
    end
  end

  def self.included mod
    mod.instance_eval do
      has_many :stuff_invisibilities, :as => :stuff, :dependent => :destroy
      has_many :itypes, :source => :character_type, :through => :stuff_invisibilities

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
