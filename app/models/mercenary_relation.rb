class MercenaryRelation < Relation
  before_create :assign_name

  def self.random_name
    @@names     ||= File.read(File.join(Rails.root, "db", "data", "names.txt")).split("\n")
    @@surnames  ||= File.read(File.join(Rails.root, "db", "data", "surnames.txt")).split("\n")

    name = @@names[rand(@@names.size)].capitalize
    surname = @@surnames[rand(@@surnames.size)].capitalize

    "#{name} #{surname}"
  end

  protected

  def assign_name
    self.name = self.class.random_name
  end
end
