require "spec_helper"

describe AWSConfig::ConfigEntry do
  subject {
    described_class.new(
      "aws_access_key_id"     => "DefaultAccessKey01",
      "aws_secret_access_key" => "Default/Secret/Access/Key/02",
      "region"                => "us-west-1"
    )
  }

  describe "#config_hash" do
    it "returns a hash for aws-sdk-ruby's configuration format" do
      expect(subject.config_hash).to eq({
        access_key_id:      "DefaultAccessKey01",
        secret_access_key:  "Default/Secret/Access/Key/02",
        region:             "us-west-1"
      })
    end
  end

  describe "#merge!" do
    let(:other_profile) {
      described_class.new(
        "aws_access_key_id" => "OtherAccessKey01",
        "output"            => "json"
      )
    }

    it "overwrites current values with other profile data" do
      subject.merge!(other_profile)
      expect(subject.aws_access_key_id).to eq("OtherAccessKey01")
      expect(subject.output).to eq("json")
      expect(subject.region).to eq("us-west-1")
    end
  end

  it "responds to methods whose names are same as given entries" do
    expect(subject).to respond_to(:aws_access_key_id)
    expect(subject).to respond_to(:aws_secret_access_key)
    expect(subject).to respond_to(:region)
  end

  it "returns given entries via methods" do
    expect(subject.aws_access_key_id).to eq("DefaultAccessKey01")
    expect(subject.aws_secret_access_key).to eq("Default/Secret/Access/Key/02")
    expect(subject.region).to eq("us-west-1")
  end

  it "returns given entries via hash-like methods" do
    expect(subject[:aws_access_key_id]).to eq("DefaultAccessKey01")
    expect(subject[:aws_secret_access_key]).to eq("Default/Secret/Access/Key/02")
    expect(subject[:region]).to eq("us-west-1")
  end

  it "raises an  exception if unknown entry is called via methods" do
    expect { subject.unknown_method }.to raise_error(NoMethodError)
  end

  context "with source_profile" do
    let(:source_profile) do
      described_class.new(
        "region"                => "ap-southeast-2",
        "aws_access_key_id"     => "SourcedAccessKey01",
        "aws_secret_access_key" => "Sourced/Secret/Access/Key/02"
      )
    end

    subject do
      described_class.new(
        "region"       => "us-west-1",
        "sourced_data" => source_profile
      )
    end

    it "returns values defined in the profile if they exist" do
      expect(subject.region).to eq("us-west-1")
    end

    it "returns values from the source profile when profile does not include the values" do
      expect(subject.aws_access_key_id).to eq("SourcedAccessKey01")
    end

    it "raises an exception when the field is missing in both profile and source profile" do
      expect { subject.unknown_field }.to raise_error(NoMethodError)
    end
  end
end
