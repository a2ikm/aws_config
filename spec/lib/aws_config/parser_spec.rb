require "spec_helper"

describe AWSConfig::Parser do
  describe "#tokenize" do
    subject { described_class.new.send(:tokenize, string) }

    context "only default profile" do
      let(:string) { <<-EOC }
[default]
aws_access_key_id=DefaultAccessKey01
aws_secret_access_key=Default/Secret/Access/Key/02
region=us-west-1
      EOC
      it { should eq({
        "default" => {
          "aws_access_key_id" => "DefaultAccessKey01",
          "aws_secret_access_key" => "Default/Secret/Access/Key/02",
          "region" => "us-west-1" }
      }) }
    end

    context "with nesting" do
      let(:string) { <<-EOC }
[default]
region=us-east-1
s3=
  max_concurrent_requests=100101
  max_queue_size=20
output=json
      EOC
      it { should eq({
        "default" => {
          "region" => "us-east-1",
          "s3" => {
            "max_concurrent_requests" => "100101",
            "max_queue_size" => "20"
          },
          "output" => "json" }
      }) }
    end

    context "invalid nesting" do
      let(:string) { <<-EOC }
[default]
region=us-east-1
s3=
  max_concurrent_requests=100101
output=json
  max_queue_size=20
      EOC
      it "raises an exception" do
        expect { subject }.to raise_error(RuntimeError, "Nesting without a parent error")
      end
    end

    context "multiple nesting" do
      let(:string) { <<-EOC }
[default]
region=us-east-1
s3=
  max_concurrent_requests=100101
  max_queue_size=20
output=json
api_versions =
    ec2 = 2015-03-01
    cloudfront = 2015-09-17
      EOC
      it { should eq({
        "default" => {
          "region" => "us-east-1",
          "s3" => {
            "max_concurrent_requests" => "100101",
            "max_queue_size" => "20"
          },
          "output" => "json",
          "api_versions" => {
            "ec2" => "2015-03-01",
            "cloudfront" => "2015-09-17"
          } }
      }) }
    end

    context "default and named profiles" do
      let(:string) { <<-EOC }
[default]
aws_access_key_id=DefaultAccessKey01

[profile testing]
aws_access_key_id=TestingAccessKey03
      EOC
      it { should eq({
        "default" => { "aws_access_key_id" => "DefaultAccessKey01" },
        "testing" => { "aws_access_key_id" => "TestingAccessKey03" }
      })}

      context "Comment line" do
        let(:string) { <<-EOC }
[default]
# THIS IS COMMENT #
aws_access_key_id=DefaultAccessKey01
        EOC
        it { should eq({
          "default" => { "aws_access_key_id" => "DefaultAccessKey01" }
        }) }
      end

      context "Blank line" do
        let(:string) { <<-EOC }
[default]


aws_access_key_id=DefaultAccessKey01
        EOC
        it { should eq({
          "default" => { "aws_access_key_id" => "DefaultAccessKey01" }
        }) }
      end
    end

    context "in credential file mode" do
      subject do
        sut = described_class.new
        sut.credential_file_mode = true
        sut.send(:tokenize, string)
      end
      context "with only the default profile" do
        let(:string) { <<-EOC }
[default]
aws_access_key_id=DefaultAccessKey01
aws_secret_access_key=Default/Secret/Access/Key/02
        EOC
        it { should eq({
          "default" => {
            "aws_access_key_id" => "DefaultAccessKey01", "aws_secret_access_key" => "Default/Secret/Access/Key/02"
           }
        }) }
      end

      context "with the default and named profiles" do
        let(:string) { <<-EOC }
[default]
aws_access_key_id=DefaultAccessKey01

[testing]
aws_access_key_id=TestingAccessKey03
        EOC
        it { should eq({
          "default" => { "aws_access_key_id" => "DefaultAccessKey01" },
          "testing" => { "aws_access_key_id" => "TestingAccessKey03" }
        }) }
      end
    end
  end
end
