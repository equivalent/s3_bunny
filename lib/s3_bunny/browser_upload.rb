module S3Bunny
  class BrowserUpload
    attr_writer :options, :key_generator, :success_action_status, :acl
    attr_accessor :resource_type
    attr_accessor :resource_id

    def initialize(region:, credentials:, bucket_name:)
      @region = region
      @credentials = credentials
      @bucket_name = bucket_name
    end

    def presigned_post
      bucket_resource.presigned_post(options)
    end

    def options
      @options || {
        key: key_generator.call,
        success_action_status: success_action_status,
        acl: acl,
        metadata: {
          'app-resource-type' => resource_type,
          'app-resource-id' =>   resource_id.to_s,
          'original-filename' => '${filename}'   # this is AWS S3 keywoard suggar.
        }
      }
    end

    def acl
      @acl || 'public-read'
    end

    def key_generator
      @key_generator || -> { "uploads/#{SecureRandom.uuid}" }
    end

    def success_action_status
      @success_action_status || '201' # must be string
    end

    private
      attr_reader :credentials, :region, :bucket_name

      def bucket_resource
        @bucket_resource ||= S3Bunny.bucket_resource({
          region: region,
          credentials: credentials,
          bucket_name: bucket_name
        })
      end
  end
end
