require "spec_helper"

describe AWSConfig do
  let(:sample_config_file) { File.expand_path("../../samples/config.txt", __FILE__) }
  let(:sample_creds_file) { File.expand_path("../../samples/credentials.txt", __FILE__) }
  before do
    AWSConfig.config_file = sample_config_file
    AWSConfig.credentials_file = sample_creds_file
  end

  it "should return an entry in a profile via method" do
    expect(described_class.default.aws_access_key_id).to eq "DefaultAccessKey01"
    expect(described_class.default.region).to eq "us-west-1"
    expect(described_class.default.output).to eq "json"
    expect(described_class.default.s3.max_concurrent_requests).to eq "100101"
    expect(described_class.default.s3.max_queue_size).to eq "20"
  end

  it "should return an entry in a profile like hashes" do
    expect(described_class["default"]["aws_access_key_id"]).to eq "DefaultAccessKey01"
    expect(described_class["default"]["region"]).to eq "us-west-1"
    expect(described_class["default"]["output"]).to eq "json"
    expect(described_class["default"]["s3"]["max_concurrent_requests"]).
      to eq "100101"
    expect(described_class["default"]["s3"]["max_queue_size"]).to eq "20"
  end
end
