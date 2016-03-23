require 'spec_helper'

RSpec.describe S3Bunny::Setup do
  subject(:bunny_setup) { described_class.new setup_hash }

  let(:setup_hash) do
    {
      :aws_access_key_id => 'my_aws_id',
      :aws_secret_access_key => 'my_aws_key',
      :queues => [
        {
          region_name: 'eu-west-1',
          bucket_name: 'eu-s3-bucket-name',
          url: 'https://sqs.eu-west-1.amazonaws.com/666666666666/my-app-queue'
        },
        {
          region_name: 'ap-southeast-2',
          bucket_name: 'ap-s3-bucket-name',
          url: 'https://sqs.ap-southeast-2.amazonaws.com/666666666666/my-app-queue'
        }
      ]
    }
  end

  describe '#credentials' do
    it 'should be aws credentials' do
      expect(subject.credentials).to be_kind_of Aws::Credentials
    end

    it 'should have id' do
      expect(subject.send(:aws_access_key_id)).to eq 'my_aws_id'
    end

    it 'should have key' do
      expect(subject.send(:aws_secret_access_key)).to eq 'my_aws_key'
    end
  end

  describe '#queues' do
    it 'should be aws credentials' do
      expect(subject.queues).to be_kind_of Array
      expect(subject.queues.size).to be 2
    end

    describe 'item' do
      subject(:queue_item) { bunny_setup.queues.last }

      it 'to have region_name' do
        expect(subject.region_name).to eq 'ap-southeast-2'
      end

      it 'to have bucket_name' do
        expect(subject.bucket_name).to eq 'ap-s3-bucket-name'
      end

      it 'to have url' do
        expect(subject.url).to eq 'https://sqs.ap-southeast-2.amazonaws.com/666666666666/my-app-queue'
      end
    end
  end
end
