module S3Bunny
  class SQSMessages
    attr_reader :queues_matcher

    def initialize(queues_matcher:,credentials:, region:)
      @credentials    = credentials
      @region         = region
      @queues_matcher = queues_matcher
    end

    def messages
      @messages ||= matching_sqs_queue_urls
        .map { |queue_url| MessagesFactory.new(self, queue_url).messages }
        .flatten
    end

    def messages!
      messages.select do |message|
        message.valuable?.tap { |valuable| message.delete unless valuable}
      end
    end

    private
      attr_reader :credentials, :region

      def matching_sqs_queue_urls
        sqs
          .list_queues
          .queue_urls
          .select { |sqs_url| sqs_url.match(queues_matcher)  }
      end

      def sqs
        @sqs ||= Aws::SQS::Client.new(region: region, credentials: credentials)
      end
  end
end
