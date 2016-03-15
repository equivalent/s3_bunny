module S3Bunny
  class Message
    attr_reader :sqs_message

    def initialize(sqs_message, credentials:, region: )
      @sqs_message = sqs_message
      @credentials = credentials
      @region = region
    end

    def message_id
      sqs_message.message_id
    end

    def transaction
      yield self
      puts "aaaaaaaaaaaaaaaaa"
    end

    def s3_items
      @s3_items ||= S3ItemFactory
        .new(raw_body, credentials: credentials, region: region)
        .s3_items
    end

    def inspect
      "#<#{self.class.name}:#{object_id} message_id:\"#{message_id}\ Objects: #sqs_message, #s3_items>"
    end

    private
      attr_reader :credentials, :region

      def receipt_handle
        sqs_message.receipt_handle
      end

      def raw_body
        sqs_message.body
      end
  end
end
