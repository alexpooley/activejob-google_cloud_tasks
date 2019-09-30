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
    let(:attributes) { double '[]': nil, has_key?: false }
    let(:task) { Activejob::GoogleCloudTasks::Task.new(job, attributes) }

    before { adapter.enqueue(job, attributes) }

    it 'create task with specified attributes' do
      allow(Activejob::GoogleCloudTasks::Task).to receive(:new).and_return task
      expect(client).to have_received(:create_task).with(queue, task.to_h)
    end
  end
end
