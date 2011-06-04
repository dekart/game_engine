Facebooker2.load_facebooker_yaml

ActionController::Base.asset_host = Proc.new{|source, request|
  Rails.logger.debug request.protocol
  Facebooker2.callback_url(request.protocol) unless ENV['OFFLINE']
}