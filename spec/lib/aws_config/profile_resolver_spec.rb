require "spec_helper"

describe AWSConfig::ProfileResolver do
  let(:default_profile) do
    AWSConfig::ConfigEntry.new(
      "aws_access_key_id"     => "DefaultAccessId01",
      "aws_secret_access_key" => "DefaultSecretKey01",
      "region"                => "us-west-1"
    )
  end
  let(:testing_profile) do
    AWSConfig::ConfigEntry.new(
      "aws_access_key_id"     => "TestingAccessId01",
      "aws_secret_access_key" => "TestingSecretKey01",
      "region"                => "us-west-1"
    )
  end
  let(:profile_with_source) do
    AWSConfig::ConfigEntry.new(
      "region"         => "ap-southeast-2",
      "source_profile" => "testing"
    )
  end

  describe "#add" do
    context "when all sources have profiles defined" do
      let(:profiles) do
        {
          "default" => default_profile,
          "testing" => testing_profile,
          "with_source" => profile_with_source
        }
      end

      it "copies sourced profile data" do
        subject.add(profiles)
        expect(profiles["with_source"].sourced_data).to eq(testing_profile)
      end
    end

    context "when sourced profiles do not exist" do
      let(:unresolving) do
        AWSConfig::ConfigEntry.new(
          "aws_access_key_id"     => "UnresolvingAccessId01",
          "aws_secret_access_key" => "UnresolvingSecretKey01",
          "region"                => "us-west-1",
          "source_profile"        => "doesnt_exist"
        )
      end

      let(:missing_profile) do
        AWSConfig::ConfigEntry.new(
          "aws_session_token" => "uk-west-2"
        )
      end
      let(:profiles) do
        {
          "default" => default_profile,
          "testing" => testing_profile,
          "with_source" => profile_with_source,
          "unresolving" => unresolving
        }
      end

      it "leaves sourced profile data empty" do
        subject.add(profiles)
        expect(profiles["unresolving"].sourced_data).to eq({})
      end

      it "copies data of the missing profile if it is added later" do
        subject.add(profiles)
        subject.add("doesnt_exist" => missing_profile)
        expect(profiles["unresolving"].sourced_data).to be missing_profile
      end
    end
  end
end
