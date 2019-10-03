require 'uri'

module Activejob
  module GoogleCloudTasks
    class Config
      DEFAULT_ENDPOINT = '/activejobs'
      DEFAULT_HTTP_METHOD = 'POST'

      class << self
        attr_writer :endpoint

        def endpoint
          @endpoint.presence || DEFAULT_ENDPOINT
        end

        # Return the path component of endpoint. Useful for knowing where
        # to mount the Rack handler.
        def path
          URI.parse(endpoint).path
        end

        def http_method
          DEFAULT_HTTP_METHOD
        end
      end
    end
  end
end
