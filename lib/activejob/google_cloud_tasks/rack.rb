require 'rack'

# Rack handler endpoint to perform the task.
#
# Expects a `QUERY_STRING` that contains a `job` and `params` key.
#
# Where:
# - `job` is the name of the handler class
# - `params` is a serialized string of arguments for the handler
#
module Activejob
  module GoogleCloudTasks
    class Rack
      class << self
        def call(env)
          task_str = env['rack.input'].read
          task = JSON.parse(task_str) rescue nil

          unless task.has_key?('job_class')
            raise StandardError, "Job is not specified."
          end

          job = klass(task['job_class'])
          job.deserialize(task)
          puts job.inspect
          job.perform_now

          [200, {}, ['ok']]
        end

        private

        def klass(job)
          Kernel.const_get(job)
        end

        def parsed_params(query_string)
          params = ::Rack::Utils.parse_nested_query(query_string)
          HashWithIndifferentAccess.new params
        end

      end
    end
  end
end
