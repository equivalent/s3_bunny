module S3Bunny
  class Interface
    UnknownRegionName = Class.new(StandardError)

    attr_reader :setup_hash

    def initialize(setup_hash)
      @setup_hash = setup_hash
    end

    def credentials
      Aws::Credentials.new(aws_access_key_id, aws_secret_access_key)
    end

    def queues
      setup_hash.fetch(:queues).map { |q_hash| OpenStruct.new(q_hash) }
    end

    def browser_upload(region:)
      bucket_name = queue_for_region(region).bucket_name

      S3Bunny::BrowserUpload
        .new(region: region, credentials: credentials, bucket_name: bucket_name)
    end

    def sqs_collector
      S3Bunny::SQSMessageCollector
        .new(credentials: credentials)
        .tap do |collector|
          queues.each do |q|
            collector.register(url: q.url, region: q.region_name)
          end
        end
    end

    def queue_for_region(region)
      queues
        .select { |q| q.region_name == region }
        .first || raise(UnknownRegionName)
    end

    private
      def aws_access_key_id
        setup_hash.fetch(:aws_access_key_id)
      end

      def aws_secret_access_key
        setup_hash.fetch(:aws_secret_access_key)
      end
  end
end
