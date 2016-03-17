require 'aws-sdk'
require 'forwardable'
require 'logger'
require "s3_bunny/version"
require "s3_bunny/config"
require "s3_bunny/factories/messages_factory"
require "s3_bunny/factories/s3_item_factory"
require "s3_bunny/sqs_message_collector"
require "s3_bunny/message"
require "s3_bunny/s3_item"
require "s3_bunny/browser_upload"

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
