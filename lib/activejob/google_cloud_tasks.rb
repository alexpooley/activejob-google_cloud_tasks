module Activejob
  module GoogleCloudTasks
    autoload :Adapter, 'activejob/google_cloud_tasks/adapter'
    autoload :Task,    'activejob/google_cloud_tasks/task'
    autoload :Config,  'activejob/google_cloud_tasks/config'
    autoload :Rack,    'activejob/google_cloud_tasks/rack'
    autoload :VERSION, 'activejob/google_cloud_tasks/version'
  end
end
