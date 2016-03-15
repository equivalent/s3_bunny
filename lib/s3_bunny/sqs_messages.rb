module S3Bunny
  class SQSMessages
    def initialize(credentials:, region:)
      @credentials = credentials
      @region = region
    end

    def messages
      all_queue_messages.map do |sqs_message_object|
        Message.new(sqs_message_object, credentials: credentials, region: region)
      end
    end

    private
      attr_reader :credentials, :region

      def all_queue_messages
        sqs
          .list_queues
          .queue_urls
          .map do |queue_url|
            logger.debug "Fetching messages from queue_url: #{queue_url}"
            sqs.receive_message(queue_url: queue_url)
          end
          .select do |client_response|
             # Seahorse::Client::Response, use only successful ones
            client_response.successful?
          end
          .map { |response| response.messages }
          .flatten
      end

      def sqs
        @sqs ||= Aws::SQS::Client.new(region: region, credentials: credentials)
      end

      def logger
        S3Bunny.logger
      end
  end
end
