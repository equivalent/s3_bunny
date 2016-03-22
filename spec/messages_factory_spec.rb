require 'spec_helper'

RSpec.describe S3Bunny::MessagesFactory do
  let(:subject) { described_class.new(queue, credentials: credentials) }
  let(:credentials) { double :credentials }
  let(:sqs_url) { 'https://sqs.eu-west-1.amazonaws.com/666666666666/sqs-name-s3bunny-development' }
  let(:sqs) { instance_double(Aws::SQS::Client) }
  let(:successful) { true }

  let(:queue) do
    instance_double S3Bunny::Queue,
      region: 'eu-west-1',
      url: sqs_url,
      sqs: sqs
  end

  let(:message) do
    instance_double(Aws::SQS::Types::Message,
       message_id:"d9caa0be-c9b8-486a-adac-5585e260d24f",
       receipt_handle:"AQEB9Is/kNbuL/LzBvKofmEIWH8L4u11dvGoXBo10706OajOg8dqT8e6WcJ5TaUhdFCR8NXiaP0uyrTNCM3J59cGUQcHZ8xoA1tmj9ZggrMCsO7PM0krXFp+xNOCOfhWrqLxvc464BIRwNBKsqye7vzWplAV5HVgY+T5gVI0e8K3c/QZpkv7NH2HrZm+3mrsSlJSsQQhbq5jPW+GQghaJ3WyU0eammvJRGMlCqmuGdBzc9R0Bwm7OLwdFQU2kft1J33t7zJhfzVPvsFwZNZJX6nsUc9mbIKJtinJ0TpEYF15Nbtwx9bjVbCYuo9lahxlB4T6Y31ZIfWyIKtjuRJK7PjhsLr5p47F4KIutjx09xShri5SzqHJjB+6k+n1Gyo8V/Lfl0kXpgqZOS6y8GM62755x4Gc7MmkBfmB3/+w4sUhZXw=",
       md5_of_body:"32db9ab188a2e0800d0d60ab669ffa2d",
       body:"{\"Records\":[{\"eventVersion\":\"2.0\",\"eventSource\":\"aws:s3\",\"awsRegion\":\"eu-west-1\",\"eventTime\":\"2016-03-17T10:44:27.067Z\",\"eventName\":\"ObjectCreated:Post\",\"userIdentity\":{\"principalId\":\"AWS:AIDAIXX7DE2N2WYDYLKIQ\"},\"requestParameters\":{\"sourceIPAddress\":\"88.150.137.140\"},\"responseElements\":{\"x-amz-request-id\":\"919838DCF81B6C53\",\"x-amz-id-2\":\"IyVXRS7rsm4kKCOcuvqwGCHIxTioXuIPM4BR062CDcOkYckQEv6eiWhw0Qj9a0nSXpPXRWTzRXA=\"},\"s3\":{\"s3SchemaVersion\":\"1.0\",\"configurationId\":\"upload\",\"bucket\":{\"name\":\"pobble.com-browser-uploads-development\",\"ownerIdentity\":{\"principalId\":\"A201HIJ10G0XZA\"},\"arn\":\"arn:aws:s3:::pobble.com-browser-uploads-development\"},\"object\":{\"key\":\"uploads/0f6dc626-71a7-4391-9c14-cf5a3d8a09de\",\"size\":37571,\"eTag\":\"2ca8646bd1db4428a2d5b61c78cd110d\",\"sequencer\":\"0056EA8A8AEFD10072\"}}}]}",
       attributes:{},
       md5_of_message_attributes:nil,
       message_attributes:{})
  end

  let(:seahorse_response) do
    # seahorse is a delgator object that delegates messages to Aws::SQS::Types::ReceiveMessageResult
    # therefore I cannot use
    #
    #   instance_double(Aws::SQS::Types::ReceiveMessageResult, ...)
    #
    # ...neither
    #
    #   instance_double(Seahorse::Client::Response)
    #
    # That's why it's plain double in this test
    #
    double("Seahorse Client Response", messages: [message], successful?: successful)
  end

  describe '#messages' do
    before do
      expect(sqs)
        .to receive(:receive_message)
        .and_return(seahorse_response)
    end

    let(:message_object) { subject.messages.last }

    it 'should properly build message' do
      expect(subject.messages).to be_kind_of Array
      expect(subject.messages.size).to be 1

      expect(message_object).to be_kind_of S3Bunny::Message
    end

    it 'should set message id' do
      expect(message_object.message_id).to eq "d9caa0be-c9b8-486a-adac-5585e260d24f"
    end

    it 'should set queue url' do
      expect(message_object.sqs_queue_url).to eq sqs_url
    end

    it 'should delegate credentials' do
      expect(message_object.send(:credentials)).to be credentials
    end

    it 'should delegate sqs client' do
      expect(message_object.send(:sqs)).to be sqs
    end
  end
end
