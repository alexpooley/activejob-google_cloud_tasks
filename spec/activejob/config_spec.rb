require_relative '../spec_helper.rb'

RSpec.describe Activejob::GoogleCloudTasks::Config do
  subject { Activejob::GoogleCloudTasks::Config }

  it "default endpoint" do
    expect(subject.endpoint).to eq '/activejobs'
  end

  it "endpoint=" do
    subject.endpoint = '/jobs'
    expect(subject.endpoint).to eq '/jobs'
  end

  describe 'path' do
    context 'endpoint is URL' do
      before { subject.endpoint = 'http://my-app.com/some-path' }
      it { expect(subject.path).to eq '/some-path' }
    end

    context 'endpoint is a path' do
      before { subject.endpoint = '/some-path' }
      it { expect(subject.path).to eq '/some-path' }
    end
  end

  it "default http_method" do
    expect(subject.http_method).to eq :GET
  end

  it "http_method=" do
    subject.http_method = :POST
    expect(subject.http_method).to eq :POST
  end

end
