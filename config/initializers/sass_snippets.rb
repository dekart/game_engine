module Sass::Script::Functions
  def hex(decimal)
    Sass::Script::String.new("%02x" % decimal)
  end
end