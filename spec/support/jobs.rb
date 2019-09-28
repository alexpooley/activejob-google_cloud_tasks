def make_job(klass_name, queue_name)
  eval <<-JOB
    class #{klass_name} < ActiveJob::Base
      queue_as "#{queue_name}"
      def perform
      end
    end
  JOB
end
