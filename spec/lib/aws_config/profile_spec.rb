require "spec_helper"

describe AWSConfig::Profile do
  subject {
    AWSConfig::Profile.new(
      "default",
      "aws_access_key_id"     => "DefaultAccessKey01",
      "aws_secret_access_key" => "Default/Secret/Access/Key/02",
      "region"                => "us-west-1"
    )
  }

  it "should return given name via method" do
    expect(subject.name).to eq "default"
  end

  it "should respond to methods whose names are same as given entries" do
    expect(subject).to respond_to :aws_access_key_id
    expect(subject).to respond_to :aws_secret_access_key
    expect(subject).to respond_to :region
  end

  it "should return given entries via methods" do
    expect(subject.aws_access_key_id).to eq "DefaultAccessKey01"
    expect(subject.aws_secret_access_key).to eq "Default/Secret/Access/Key/02"
    expect(subject.region).to eq "us-west-1"
  end

  it "should return given entries via hash-like methods" do
    expect(subject[:aws_access_key_id]).to eq "DefaultAccessKey01"
    expect(subject[:aws_secret_access_key]).to eq "Default/Secret/Access/Key/02"
    expect(subject[:region]).to eq "us-west-1"
  end

  it "should raise exceptions if unknown entry is called via methods" do
    expect { subject.unknown_method }.to raise_error NoMethodError
  end
end
