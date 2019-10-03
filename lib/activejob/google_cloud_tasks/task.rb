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
            relative_uri: endpoint.to_s,
            body: body.to_json
          }
        }
      end

      def http_task
        {
          http_request: {
            http_method: http_method,
            url: endpoint.to_s,
            body: body.to_json
          }
        }
      end

      def endpoint
        uri = @job.endpoint if @job.respond_to?(:endpoint)
        uri ||= Activejob::GoogleCloudTasks::Config.endpoint
        URI.parse(uri)
      end

      def body
        @job.serialize
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
        method = @job.http_method if @job.respond_to?(:http_method)
        method || Activejob::GoogleCloudTasks::Config.http_method
      end

    end
  end
end
