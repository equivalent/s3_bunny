module S3Bunny
  class SQSMessageCollector
    attr_reader :queues

    def initialize(credentials:)
      @credentials = credentials
      @queues = []
    end

    def messages
      @messages ||= queues
        .map { |queue| MessagesFactory.new(queue, credentials: credentials).messages }
        .flatten
    end

    def messages!
      messages.select do |message|
        message.valuable?.tap { |valuable| message.delete unless valuable}
      end
    end

    def register(region:, url:)
      queues << Queue.new(region: region, url: url, credentials: credentials)
    end

    private
      attr_reader :credentials
  end
end
