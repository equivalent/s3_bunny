module S3Bunny
  class S3Item
    attr_reader :region, :bucket_name, :file

    def initialize(credentials:, region:, bucket_name:, file:)
      @bucket_name = bucket_name
      @credentials = credentials
      @region = region
      @file = file
    end

    def url
      s3_object.presigned_url(:get, expires_in: url_expiry)
    end

    def metadata
      s3_object.metadata
    end

    def inspect
      "#<#{self.class.name}:#{object_id} s3://#{bucket_name}/#{file}>"
    end

    private
      attr_reader :credentials

      def s3_object
        @s3_object ||= S3Bunny
          .bucket_resource({
            region: region,
            credentials: credentials,
            bucket_name: bucket_name
          })
          .object(file)
      end

      def url_expiry
        S3Bunny.config.default_url_expires_in
      end
  end
end
