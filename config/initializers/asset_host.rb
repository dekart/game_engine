ActionController::Base.asset_host = Proc.new{|source, request|
  Facepalm::Config.default.callback_url(request ? request.protocol : 'http://') unless ENV['OFFLINE'] || Rails.env.development?
}