module ActionController
  class PostCanvasMiddleware
    def initialize(app, options = {})
      @app = app
    end
    
    def call(env)
      request = Rack::Request.new(env)
      
      if request.params['signed_request'] && request.post? && request.params['_method'].blank?
        env['REQUEST_METHOD'] = 'GET'
      end
      
      @app.call(env)
    end
  end
end