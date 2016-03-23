require 'spec_helper'

RSpec.describe S3Bunny::SQSMessageCollector do
  let(:credentials) { instance_double(Aws::Credentials) }

  subject(:collector) { described_class.new(credentials: credentials) }

  describe '#register' do
    it 'should register queue' do
      expect(subject.queues).to be_empty

      subject.register(region: 'foo', url: 'http://bar')
      subject.register(region: 'car', url: 'http://dar')

      expect(subject.queues.size).to be 2

      expect(subject.queues.last.region).to eq 'car'
      expect(subject.queues.last.url).to eq 'http://dar'
    end
  end
end
