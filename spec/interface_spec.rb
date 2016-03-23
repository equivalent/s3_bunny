require 'spec_helper'

RSpec.describe S3Bunny::Interface do
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

  describe '#queue_for_region' do
    let(:queue_item) { subject.queue_for_region(region) }

    context 'when registered region' do
      let(:region) { 'eu-west-1' }

      it do
        expect(queue_item.bucket_name).to eq 'eu-s3-bucket-name'
      end
    end

    context 'when unregistered region' do
      let(:region) { 'us-west-1' }

      it do
        expect { queue_item.bucket_name }.to raise_error(S3Bunny::Interface::UnknownRegionName)
      end
    end
  end

  describe '#browser_upload' do
    it 'should initialized BrowserUpload object with setup' do
      credentials = instance_double(Aws::Credentials)

      expect(Aws::Credentials)
        .to receive(:new)
        .and_return(credentials)

      expect(S3Bunny::BrowserUpload)
        .to receive(:new)
        .with(region: 'eu-west-1', credentials: credentials, bucket_name: 'eu-s3-bucket-name')
        .and_call_original

      expect(subject.browser_upload(region: 'eu-west-1')).to be_kind_of(S3Bunny::BrowserUpload)
    end
  end

  describe '#sqs_collector' do
    it 'should return SQSMessageCollector' do
      expect(subject.sqs_collector).to be_kind_of S3Bunny::SQSMessageCollector
    end

    it 'it should register all queues from setup' do
      expect(subject.sqs_collector.queues.size).to be 2
      expect(subject.sqs_collector.queues.last.url).to eq 'https://sqs.ap-southeast-2.amazonaws.com/666666666666/my-app-queue'
    end
  end
end
