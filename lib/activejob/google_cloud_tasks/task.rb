# Translate an ActiveJob object to a Google Cloud Task hash body.
#
# Depending on configured endpoint a http target, or app engine target task
# will be constructed.
module Activejob
  module GoogleCloudTasks
    class Task

      GPT = Google::Protobuf::Timestamp

      def initialize(job, attributes = {})
        @job = job
        @attributes = attributes
      end

      def to_h
        task = public_send(request_type)

        if @attributes.has_key?(:wait_until)
          task[:schedule_time] = GPT.new(seconds: @attributes[:wait_until].to_i)
        end

        if @attributes.has_key?(:wait)
          task[:schedule_time] = GPT.new(seconds: (Time.now+@attributes[:wait]).to_i)
        end

        task
      end

      def app_engine_task
        {
          app_engine_http_request: {
            http_method: http_method,
            relative_uri: url.to_s
          }
        }
      end

      def http_task
        {
          http_request: {
            http_method: http_method,
            url: url.to_s
          }
        }
      end

      def url
        suffix = "/perform?job=#{@job.class.to_s}&#{@job.arguments.to_query('params')}"
        case endpoint
        when URI::HTTP, URI::HTTPS
          URI.join endpoint, suffix
        when URI::Generic
          endpoint.to_s + suffix
        end
      end

      def endpoint
        URI.parse @attributes[:endpoint] ||
                  Activejob::GoogleCloudTasks::Config.endpoint
      end

      def request_type
        case endpoint
        when URI::HTTP, URI::HTTPS
          :http_task
        when URI::Generic
          :app_engine_task
        end
      end

      def http_method
        @attributes[:http_method] ||
        Activejob::GoogleCloudTasks::Config.http_method
      end

    end
  end
end
