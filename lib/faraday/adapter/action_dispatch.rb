module Faraday
  module Adapter
    class ActionDispatch < Middleware
      attr_reader :session

      # Initializes a new middleware instance for each request.  Instead of 
      # initiating an HTTP request with a web server, this adapter calls
      # a Rails 3 app using integration tests.
      #
      # app     - The current Faraday request.
      # session - An ActionDispatch::Integration::Session instance.
      #
      # Returns nothing.
      def initialize(app, session)
        super(app)
        @session = session
        @session.reset!
      end

      def call(env)
        process_body_for_request(env)
        full_path = full_path_for(env[:url].path, env[:url].query, env[:url].fragment)
        @session.__send__(env[:method], full_path, env[:body], env[:request_headers])
        resp = @session.response
        env.update \
          :status           => resp.status,
          :response_headers => resp.headers,
          :body             => resp.body
        @app.call env
      end
    end
  end
end