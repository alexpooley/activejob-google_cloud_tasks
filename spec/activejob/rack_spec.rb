require_relative '../spec_helper.rb'
require 'rack/test'

RSpec.describe Activejob::GoogleCloudTasks::Rack do
  include Rack::Test::Methods

  before { make_job('SomeJob', 'default') }

  let(:app) { Activejob::GoogleCloudTasks::Rack }

  # TODO This test is not very good.
  it 'can perform Job' do
    job_klass = spy('GreetJob')
    expect(app).to receive(:klass) { job_klass }

    job = SomeJob.new(1, arg2: 'two')
    params = job.serialize.to_json
    post '/any-mounted-path', params
    expect(last_response.status).to eq(200)
    expect(job_klass).to have_received(:deserialize)
    expect(job_klass).to have_received(:perform_now)
  end

  it 'raises NameError for unknown job' do
    expect { get '/any-mounted-path', 'something else' }.to raise_error(NameError)
  end
end
