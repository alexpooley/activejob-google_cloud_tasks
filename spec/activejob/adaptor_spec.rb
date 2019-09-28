require_relative '../spec_helper.rb'

RSpec.describe Activejob::GoogleCloudTasks::Adapter do
  let(:client) { spy('Google::Cloud::Tasks') }
  let(:queue_name) { 'my-queue' }
  let(:project) { 'my-project' }
  let(:location) { 'my-location' }

  let(:adapter) do
    Activejob::GoogleCloudTasks::Adapter.new(
      project: project, location: location, cloud_tasks_client: client)
  end

  before do
    eval <<-JOB
      class GreetJob < ActiveJob::Base
        queue_as "#{queue_name}"
        def perform(name, suffix='!', prefix: 'hello')
          "\#{prefix} \#{name}\#{suffix}"
        end
      end
    JOB
  end


  describe '#enqueue' do
    let(:job) { GreetJob.new('foo', ':)', prefix: 'howdy') }
    let(:queue) { "projects/#{project}/locations/#{location}/queues/#{queue_name}" }

    context 'basic task' do
      before { adapter.enqueue(job) }

      it 'creates cloud tasks job' do
        task = Activejob::GoogleCloudTasks::Task.new(job)
        expect(client).to have_received(:create_task).with(queue, task.to_h)
      end
    end

    context 'scheduled task' do
      let(:scheduled_at) { 1.hour.from_now }

      before do
        adapter.enqueue(job, scheduled_at: scheduled_at)
      end

      it 'creates cloud tasks job with schedule' do
        task = Activejob::GoogleCloudTasks::Task.new(job, scheduled_at: scheduled_at)
        expect(client).to have_received(:create_task).with(queue, task.to_h)
        expect(task.to_h).to have_key :schedule_time
      end
    end

  end
end
