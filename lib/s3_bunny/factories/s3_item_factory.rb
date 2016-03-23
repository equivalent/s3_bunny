module S3Bunny
  class S3ItemFactory
    MessageBodyNotS3Format = Class.new(StandardError)

    attr_reader :raw_sqs_body

    def initialize(raw_sqs_body, credentials:, region:)
      @raw_sqs_body = raw_sqs_body
      @credentials  = credentials
      @region       = region
    end

    def s3_items
      body_to_hash.map { |file_detail| S3Bunny::S3Item.new(file_detail) }
    end

    private
      attr_reader :credentials, :region

      def body_to_hash
        begin
          body
            .fetch("Records") { |x| raise_body_not_s3_format(x) }
            .map { |message_record| record_to_hash(message_record) }
            .compact
        rescue MessageBodyNotS3Format => e
          S3Bunny.logger.warn(e.inspect)
          []
        end
      end

      def record_to_hash(record)
        begin
          region = record.fetch('awsRegion') { |x| raise_body_not_s3_format(x) }
          s3     = record.fetch('s3') { |x| raise_body_not_s3_format(x) }
          key   = s3
            .fetch('object') { |x| raise_body_not_s3_format(x) }
            .fetch('key')    { |x| raise_body_not_s3_format(x) }
          bucket_name = s3
            .fetch('bucket') { |x| raise_body_not_s3_format(x) }
            .fetch('name')   { |x| raise_body_not_s3_format(x) }

          {
            region: region,
            bucket_name: bucket_name,
            key: key,
            credentials: credentials
          }
        rescue MessageBodyNotS3Format => e
          S3Bunny.logger.warn(e.inspect)
          nil
        end
      end

      def body
        JSON.parse(@raw_sqs_body)
      end

      def raise_body_not_s3_format(x)
        raise(MessageBodyNotS3Format, "\"#{x}\" not found in body")
      end
  end
end
