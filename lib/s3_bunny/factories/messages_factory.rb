module S3Bunny
  class MessagesFactory
    extend Forwardable

    attr_reader :sqs_queue_url
    def_delegators :base, :credentials, :region, :sqs

    def initialize(base, sqs_queue_url)
      @base = base
      @sqs_queue_url = sqs_queue_url
    end

    def messages
      @messages ||= begin
        response = request_queue_messages

        S3Bunny.logger.debug response.inspect

        if response.successful?
          response
            .messages
            .map { |m| build_message(m) }
        else
          S3Bunny.logger.warning "Response of #{sqs_queue_url} not successful"
          []
        end
      end
    end

    private
      attr_reader :base

      def request_queue_messages
        S3Bunny.logger.debug "Fetching messages from sqs_queue_url: #{sqs_queue_url}"
        seahorse_response = sqs.receive_message(queue_url: sqs_queue_url)
      end

      def build_message(sqs_message_object)
        Message.new({
          sqs_queue_url: sqs_queue_url,
          sqs_message: sqs_message_object,
          credentials: credentials, # we will establishing s3 connection later on
          sqs: sqs,                 # pass current sqs connection
          region: region
        })
      end
  end
end
