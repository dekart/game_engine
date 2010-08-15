module ActionController
  module Session
    class MemCacheStoreWithHeaders < MemCacheStore
      private

      def load_session(env)
        request = Rack::Request.new(env)
        sid = request.cookies[@key]
        unless @cookie_only
          sid ||= request.params['_session_id'] || request.env['HTTP_SESSION_ID']
        end
        sid, session = get_session(env, sid)
        [sid, session]
      end
    end
  end
end