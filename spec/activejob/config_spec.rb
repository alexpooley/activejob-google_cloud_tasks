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

  it "default http_method" do
    expect(subject.http_method).to eq :GET
  end

  it "http_method=" do
    subject.http_method = :POST
    expect(subject.http_method).to eq :POST
  end

end
