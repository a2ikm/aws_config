require 'spec_helper'

describe AWSConfig::ProfileResolver do
  subject { described_class.new }

  let(:default_profile) do
    AWSConfig::Profile.new(
      'default',
      'aws_access_key_id'     => 'DefaultAccessId01',
      'aws_secret_access_key' => 'DefaultSecretKey01',
      'region'            => 'us-west-1'
    )
  end
  let(:testing_profile) do
    AWSConfig::Profile.new(
      'testing',
      'aws_access_key_id'     => 'TestingAccessId01',
      'aws_secret_access_key' => 'TestingSecretKey01',
      'region'            => 'us-west-1'
    )
  end
  let(:profile_with_source) do
    AWSConfig::Profile.new(
      'with_source',
      'region'     => 'ap-southeast-2',
      'source_profile' => 'testing'
    )
  end
  describe '#add' do
    context 'when all profiles resolve' do
      let(:profiles) do
        {
          default_profile.name     => default_profile,
          testing_profile.name     => testing_profile,
          profile_with_source.name => profile_with_source
        }
      end

      it 'resolves the sources' do
        subject.add profiles
        expect(profiles['with_source'].source_profile).to be testing_profile
      end
    end

    context 'when some profles do not resolve' do
      let(:unresolving) do
        AWSConfig::Profile.new(
          'unresolving',
          'aws_access_key_id'     => 'UnresolvingAccessId01',
          'aws_secret_access_key' => 'UnresolvingSecretKey01',
          'region'            => 'us-west-1',
          'source_profile'        => 'doesnt_exist'
        )
      end

      let(:missing_profile) do
        AWSConfig::Profile.new(
          'doesnt_exist',
          'aws_session_token' => 'uk-west-2'
        )
      end
      let(:profiles) do
        {
          default_profile.name     => default_profile,
          testing_profile.name     => testing_profile,
          profile_with_source.name => profile_with_source,
          unresolving.name         => unresolving
        }
      end

      it 'resolves the sources it can' do
        subject.add profiles
        expect(profiles['with_source'].source_profile).to be testing_profile
      end

      it 'should remember the unresolved source profile' do
        subject.add profiles
        expect(subject.wanted_profiles).to eq('doesnt_exist' => ['unresolving'])
      end

      it 'should resolve the missing profile if it is added later' do
        subject.add profiles
        expect(subject.wanted_profiles).to eq('doesnt_exist' => ['unresolving'])
        subject.add missing_profile.name => missing_profile
        expect(subject.wanted_profiles).to eq({})
        expect(subject.profiles['unresolving'].source_profile).to be missing_profile
      end
    end
  end
end
