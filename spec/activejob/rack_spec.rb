require_relative '../spec_helper.rb'
require 'rack/test'

RSpec.describe Activejob::GoogleCloudTasks::Rack do
  include Rack::Test::Methods

  let(:app) { Activejob::GoogleCloudTasks::Rack }

  it 'can perform Job' do
    job_klass = spy('GreetJob')
    expect(app).to receive(:klass) { job_klass }

    params = { job: 'GreetJob', params: ["foo", ":)", {:prefix=>"howdy"}] }
    get '/any-mounted-path', params
    expect(last_response.status).to eq(200)
    expect(job_klass).to have_received(:perform_now).with(*params[:params])
  end

  it 'raises NameError for unknown job' do
    expect { get '/any-mounted-path', job: 'UnknownJob' }.to raise_error(NameError)
  end
end
