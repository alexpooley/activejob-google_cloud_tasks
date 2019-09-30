require 'uri'

module Activejob
  module GoogleCloudTasks
    class Config
      DEFAULT_ENDPOINT = '/activejobs'
      DEFAULT_HTTP_METHOD = :GET

      class << self
        attr_writer :endpoint, :http_method

        def endpoint
          @endpoint.presence || DEFAULT_ENDPOINT
        end

        # Return the path component of endpoint. Useful for knowing where
        # to mount the Rack handler.
        def path
          URI.parse(endpoint).path
        end

        def http_method
          @http_method.presence || DEFAULT_HTTP_METHOD
        end
      end
    end
  end
end
