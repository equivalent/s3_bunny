module S3Bunny
  class BrowserUpload
    attr_writer :options, :key_generator, :success_action_status, :acl, :content_length_range, :signature_expiration
    attr_accessor :resource_type
    attr_accessor :resource_id
    attr_accessor :custom_field

    def initialize(region:, credentials:, bucket_name:)
      @region = region
      @credentials = credentials
      @bucket_name = bucket_name
    end

    def presigned_post
      bucket_resource.presigned_post(options)
    end

    def options
      return @options if @options

      metadata = {
        'app-resource-type' => resource_type,
        'app-resource-id' =>   resource_id.to_s,
        'original-filename' => '${filename}'   # this is AWS S3 keywoard suggar.
      }

      # field needs to be a string. If you are dealing with a hash then serialize it!
      metadata.merge!({'app-custom-field' => custom_field.to_s}) if custom_field

      {
        signature_expiration: signature_expiration,
        key: key_generator.call,
        success_action_status: success_action_status,
        acl: acl,
        content_length_range: content_length_range,
        #content_type_starts_with: "image/jpg",
        key_starts_with: "uploads/",
        metadata: metadata
      }
    end

    def signature_expiration
      @signature_expiration ||= Time.now + 3600
    end

    def content_length_range
      @content_length_range ||= 0..10_485_760 #0 - 10.megabytes
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
