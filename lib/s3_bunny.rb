require "s3_bunny/version"
require "s3_bunny/config"
require "s3_bunny/sqs_messages"
require "s3_bunny/message"
require "s3_bunny/s3_item"
require "s3_bunny/s3_item_factory"

module S3Bunny
  def self.bucket_resource(region:, bucket_name:, credentials:)
    s3_client = Aws::S3::Client.new(region: region, credentials: credentials)
    Aws::S3::Bucket.new(name: bucket_name, client: s3_client)
  end

  def self.config
    @config ||= Config.new
  end

  def self.logger
    config.logger
  end
end
