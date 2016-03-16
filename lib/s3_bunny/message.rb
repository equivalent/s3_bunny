module S3Bunny
  class Message
    extend Forwardable

    attr_reader :sqs_message, :sqs_queue_url

    def initialize(sqs_queue_url:, sqs_message:, sqs:, credentials:, region: )
      @sqs_queue_url = sqs_queue_url
      @sqs_message = sqs_message
      @credentials = credentials
      @region = region
      @sqs = sqs
    end

    def message_id
      sqs_message.message_id
    end

    # Will execute what is needed and if your block is sucessfull
    # it will delete the message
    #
    #    message.transaction do
    #      s3_items
    #       .map do |item|
    #         MyModel.new(url: item.url).save # true if sucecss false if not
    #       end
    #       .select { |save_result| save_result == false }
    #       .empty? # everything was sucessful, return true => message gets deleted
    #    end
    #
    def transaction(delete_when_truthy_result: true)
      result = yield(self)
      delete if delete_when_truthy_result && result
    end

    def valuable?
      s3_items.any?
    end

    def s3_items
      @s3_items ||= S3ItemFactory
        .new(body, credentials: credentials, region: region)
        .s3_items
    end

    def inspect
      "#<#{self.class.name}:#{object_id} message_id:\"#{message_id}\ body: #{body.to_s[0, 30]}>"
    end

    def delete
      sqs.delete_message({
        queue_url: sqs_queue_url,
        receipt_handle: receipt_handle
      })
    end

    private
      attr_reader :credentials, :region, :sqs
      def_delegators :sqs_message, :receipt_handle, :body
  end
end
