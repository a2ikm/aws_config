require "spec_helper"

describe AWSConfig::Profile do
  context 'regardless of source_profile' do
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

    it "should return a hash for aws-sdk-ruby's configuration format" do
      expect(subject.config_hash).to eq({
        access_key_id:      "DefaultAccessKey01",
        secret_access_key:  "Default/Secret/Access/Key/02",
        region:             "us-west-1"
      })
    end
  end

  context 'with source_profile' do
    let(:source_profile) do
      AWSConfig::Profile.new(
        'default',
        'region'            => 'ap-southeast-2',
        'aws_access_key_id'     => 'DefaultAccessKey01',
        'aws_secret_access_key' => 'Default/Secret/Access/Key/02'
      )
    end
    subject do
      AWSConfig::Profile.new(
        'testing',
        'region'          => 'us-west-1',
        'source_profile'  => source_profile
      )
    end
    context 'when called like a method' do
      let(:region) { 'us-west-1' }
      let(:access_key_id) { 'DefaultAccesskey01' }
      it 'should return values directly on the profile' do
        expect(subject.region).to eq region
      end

      it 'should check the source profile if the desired key is missing' do
        expect(source_profile).to receive(:aws_access_key_id).and_return(access_key_id)
        expect(subject.aws_access_key_id).to eq access_key_id
      end
    end

    context 'when called like a hash' do
      let(:region) { 'us-west-1' }
      let(:access_key_id) { 'DefaultAccesskey01' }
      it 'should return values directly on the profile' do
        expect(subject['region']).to eq region
      end

      it 'should check the source profile if the desired key is missing' do
        expect(source_profile).to receive(:[]).with('aws_access_key_id').and_return(access_key_id)
        expect(subject['aws_access_key_id']).to eq access_key_id
      end
    end
  end
end
