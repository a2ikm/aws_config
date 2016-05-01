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

    context "in credential file mode" do
      subject do
        sut = described_class.new
        sut.credential_file_mode = true
        sut.send(:tokenize, string)
      end
      context "with only the default profile" do
        let(:string) do
          <<-EOC
            [default]
            aws_access_key_id=DefaultAccessKey01
            aws_secret_access_key=Default/Secret/Access/Key/02
          EOC
        end
        it { should eq [
          [:profile,    "default"],
          [:key_value,  "aws_access_key_id",      "DefaultAccessKey01"],
          [:key_value,  "aws_secret_access_key",  "Default/Secret/Access/Key/02"],
        ] }
      end

      context "with the default and named profiles" do
        let(:string) do
          <<-EOC
            [default]
            aws_access_key_id=DefaultAccessKey01

            [testing]
            aws_access_key_id=TestingAccessKey03
          EOC
        end
        it { should eq [
          [:profile,    "default"],
          [:key_value,  "aws_access_key_id",  "DefaultAccessKey01"],
          [:profile,    "testing"],
          [:key_value,  "aws_access_key_id",  "TestingAccessKey03"],
        ] }
      end
    end
  end

  describe "#build" do
    subject { described_class.new.send(:build, tokens) }

    context "Single profile" do
      let(:tokens) { [
        [:profile,    "default"],
        [:key_value,  "aws_access_key_id",      "DefaultAccessKey01"],
        [:key_value,  "aws_secret_access_key",  "Default/Secret/Access/Key/02"],
        [:key_value,  "region",                 "us-west-1"]
      ] }
      it { should eq({
        "default" => {
          "aws_access_key_id"     => "DefaultAccessKey01",
          "aws_secret_access_key" => "Default/Secret/Access/Key/02",
          "region"                => "us-west-1"
        }
      }) }
    end

    context "Multi profiles" do
      let(:tokens) { [
        [:profile,    "default"],
        [:key_value,  "aws_access_key_id",  "DefaultAccessKey01"],
        [:profile,    "testing"],
        [:key_value,  "aws_access_key_id",  "TestingAccessKey02"],
      ] }
      it { should eq({
        "default" => { "aws_access_key_id" => "DefaultAccessKey01" },
        "testing" => { "aws_access_key_id" => "TestingAccessKey02" }
      }) }
    end

    context "Twice-defined single profile" do
      let(:tokens) { [
        [:profile,    "default"],
        [:key_value,  "aws_access_key_id",      "DefaultAccessKey01"],
        [:key_value,  "region",                 "us-west-1"],
        [:profile,    "default"],
        [:key_value,  "aws_access_key_id",      "DefaultAccessKey01_ANOTHER"],
        [:key_value,  "aws_secret_access_key",  "Default/Secret/Access/Key/01"],
      ] }
      it { should eq({
        "default" => {
          "aws_access_key_id"     => "DefaultAccessKey01_ANOTHER",
          "aws_secret_access_key" => "Default/Secret/Access/Key/01",
          "region"                => "us-west-1"
        }
      }) }
    end
  end

  describe "#wrap" do
    subject { described_class.new.send(:wrap, profiles) }

    context "Single profile" do
      let(:profiles) {
        {
          "default" => {
            "aws_access_key_id"     => "DefaultAccessKey01",
            "aws_secret_access_key" => "Default/Secret/Access/Key/02",
            "region"                => "us-west-1"
          }
        }
      }
      it { should be_a Hash }
      it { should have_key "default" }
      it "should have AWSConfig::Profile as value" do
        expect(subject["default"]).to be_a AWSConfig::Profile
      end
    end
  end
end
