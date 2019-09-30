require_relative '../spec_helper.rb'

RSpec.describe Activejob::GoogleCloudTasks::Task do
  include ActiveSupport::Testing::TimeHelpers

  before(:all) do
    Activejob::GoogleCloudTasks::Config.http_method = :GET
    make_job('HelloJob', 'hello_queue')
  end
  let(:job) { HelloJob.new }
  let(:task) { described_class.new(job, {}) }


  describe '#to_h' do
    let(:task) { described_class.new(job, {}) }

    context 'when endpoint is a path' do
      before do
        Activejob::GoogleCloudTasks::Config.endpoint = '/path'
      end
      it 'return a scheduled app_engine_http_request' do
        exp = {
          app_engine_http_request: {
            http_method: :GET,
            relative_uri: task.url.to_s
          }
        }
        expect(task.to_h).to eq exp
      end
    end

    context 'when endpoint is a URL' do
      before do
        Activejob::GoogleCloudTasks::Config.endpoint = 'http://google.com'
      end
      it 'return a scheduled http_task_request' do
        exp = {
          http_request: {
            http_method: :GET,
            url: task.url.to_s
          }
        }
        expect(task.to_h).to eq exp
      end
    end

    context 'when scheduled for time' do
      let(:scheduled) { 1.hour.from_now }
      let(:task) { described_class.new(job, {wait_until: scheduled}) }
      it 'include a schedule_time param' do
        timestamp = Google::Protobuf::Timestamp.new(seconds: scheduled.to_i)
        expect(task.to_h[:schedule_time]).to eq timestamp
      end
    end

    context 'when scheduled with duration' do
      before { freeze_time }
      let(:scheduled) { 1.hour }
      let(:task) { described_class.new(job, {wait: scheduled}) }
      it 'include a schedule_time param' do
        time = (Time.now+scheduled).to_i
        timestamp = Google::Protobuf::Timestamp.new(seconds: time)
        expect(task.to_h[:schedule_time]).to eq timestamp
      end
    end
  end

  describe '#app_engine_task' do

    before do
      Activejob::GoogleCloudTasks::Config.http_method = 'POST'
      Activejob::GoogleCloudTasks::Config.endpoint = '/path'
    end

    it 'return an app_engine_http_request structure' do
      exp = {
        app_engine_http_request: {
          http_method: 'POST',
          relative_uri: task.url.to_s
        }
      }
      expect(task.app_engine_task).to eq exp
    end
  end

  describe '#http_task' do
    let(:endpoint) { 'https://google.com/path' }
    before do
      Activejob::GoogleCloudTasks::Config.http_method = :GET
      Activejob::GoogleCloudTasks::Config.endpoint = endpoint
    end
    it 'return a http_request structure' do
      exp = {
        http_request: {
          http_method: :GET,
          url: task.url.to_s
        }
      }
      expect(task.http_task).to eq exp
    end
  end


  context 'override global endpoint' do
    let(:new_endpoint) { 'abracadabra' }

    before do
      Activejob::GoogleCloudTasks::Config.endpoint = 'old_endpoint'
      job.class_eval do
        attr_accessor :endpoint
      end
    end

    it 'should replace global endpoint' do
      job.endpoint = new_endpoint

      relative_uri = task.app_engine_task[:app_engine_http_request][:relative_uri]

      expect(relative_uri).to match new_endpoint
    end
  end

  context 'override global http_method' do
    let(:new_http_method) { :DELETE }

    before do
      Activejob::GoogleCloudTasks::Config.http_method = :GET
      job.class_eval do
        attr_accessor :http_method
      end
    end

    it 'should replace global http_method' do
      job.http_method = new_http_method

      http_method = task.app_engine_task[:app_engine_http_request][:http_method]

      expect(http_method).to eq new_http_method
    end
  end

  describe '#url' do

    context 'with URL endpoint' do
      before do
        Activejob::GoogleCloudTasks::Config.endpoint = 'https://google.com'
      end
      it { expect(task.url).to be_kind_of URI::HTTPS }
    end

    context 'with path endpoint' do
      before do
        Activejob::GoogleCloudTasks::Config.endpoint = '/path'
      end
      it { expect(task.url).to be_kind_of String }
    end

  end

  describe '#endpoint' do
    let(:endpoint) { '/path' }

    it 'convert endpoint to URI' do
      Activejob::GoogleCloudTasks::Config.endpoint = endpoint
      expect(task.endpoint).to be_kind_of URI::Generic
    end
  end

  describe '#request_type' do

    context 'endpoint is a path' do
      before do
        Activejob::GoogleCloudTasks::Config.endpoint = '/path'
      end
      it { expect(task.request_type).to eq :app_engine_task }
    end

    context 'endpoint is a url' do
      before do
        Activejob::GoogleCloudTasks::Config.endpoint = 'http://google.com'
      end
      it { expect(task.request_type).to eq :http_task }
    end

  end

  describe '#http_method' do
    it 'should retrieve from Config' do
      Activejob::GoogleCloudTasks::Config.http_method = :some_method
      expect(task.http_method).to eq :some_method
    end
  end

end
