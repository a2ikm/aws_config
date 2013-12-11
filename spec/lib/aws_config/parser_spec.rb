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
      it { should eq [
        [:profile,    "default"],
        [:key_value,  "aws_access_key_id",      "DefaultAccessKey01"],
        [:key_value,  "aws_secret_access_key",  "Default/Secret/Access/Key/02"],
        [:key_value,  "region",                 "us-west-1"]
      ] }
    end

    context "default and named profiles" do
      let(:string) { <<-EOC }
[default]
aws_access_key_id=DefaultAccessKey01

[profile testing]
aws_access_key_id=TestingAccessKey03
      EOC
      it { should eq [
        [:profile,    "default"],
        [:key_value,  "aws_access_key_id",  "DefaultAccessKey01"],
        [:profile,    "testing"],
        [:key_value,  "aws_access_key_id",  "TestingAccessKey03"],
      ] }

      context "Comment line" do
        let(:string) { <<-EOC }
[default]
# THIS IS COMMENT #
aws_access_key_id=DefaultAccessKey01
        EOC
        it { should eq [
          [:profile,    "default"],
          [:key_value,  "aws_access_key_id",  "DefaultAccessKey01"]
        ] }
      end

      context "Blank line" do
        let(:string) { <<-EOC }
[default]


aws_access_key_id=DefaultAccessKey01
        EOC
        it { should eq [
          [:profile,    "default"],
          [:key_value,  "aws_access_key_id",  "DefaultAccessKey01"]
        ] }
      end
    end
  end
end
