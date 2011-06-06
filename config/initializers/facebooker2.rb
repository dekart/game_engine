Facebooker2.load_facebooker_yaml

ActionController::Base.asset_host = Proc.new{|source, request|
  Facebooker2.callback_url(request.protocol if request) unless ENV['OFFLINE']
}