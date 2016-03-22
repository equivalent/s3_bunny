module S3Bunny
  class Queue
    attr_reader :region, :url

    def initialize(region:, url:, credentials:)
      @region = region
      @url    = url
      @credentials = credentials
    end

    def sqs
      @sqs ||= Aws::SQS::Client.new(region: region, credentials: credentials)
    end

    private
      attr_reader :credentials
  end
end
