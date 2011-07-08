# This code stubs paperclip calls to speed up testing process
#
# More details can be found here:
#
# * http://grease-your-suite.heroku.com/#29
# * http://pivotallabs.com/users/rolson/blog/articles/1249-stubbing-out-paperclip-imagemagick-in-tests

module Paperclip
  def self.run cmd, params = "", expected_outcodes = 0
    case cmd
    when "identify"
      return "100x100"
    when "convert"
      return
    else
      super
    end
  end
end

class Paperclip::Attachment
  def post_process
  end
end