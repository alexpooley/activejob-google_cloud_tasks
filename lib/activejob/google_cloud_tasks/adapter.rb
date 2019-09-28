require 'activejob/google_cloud_tasks/config'
require 'google/cloud/tasks'
require 'google/cloud/tasks/v2beta3/cloud_tasks_client'

module Activejob
  module GoogleCloudTasks
    class Adapter

      def initialize(project:, location:, cloud_tasks_client: Google::Cloud::Tasks.new(version: :v2beta3))
        @project = project
        @location = location
        @cloud_tasks_client = cloud_tasks_client
      end

      def enqueue(job, attributes = {})
        queue = Google::Cloud::Tasks::V2beta3::CloudTasksClient.queue_path(@project, @location, job.queue_name)
        task = Task.new(job, attributes)
        @cloud_tasks_client.create_task(queue, task.to_h)
      end

      def enqueue_at(job, scheduled_at)
        enqueue job, scheduled_at: scheduled_at
      end

    end
  end
end
