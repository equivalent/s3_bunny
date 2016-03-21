require 'spec_helper'
require 's3_bunny/jsonapi_helper'

RSpec.describe S3Bunny::JSONAPIHelper do
  let(:presigned_post_mock) do
    instance_double Aws::S3::PresignedPost,
      url: 'http://s3-foobar',
      fields: {
        'foo' => 'bar',
        'key' => 'uploads/oeausoea-oaeuoaeu-ueouo'
      }
  end

  describe '.as_json' do
    it 'should generate JSON API alike JSON for presigned post' do
      expect(described_class.as_json(presigned_post_mock)).to match({
        "type" => "aws_s3_presigned_posts",
        "id"=> "uploads/oeausoea-oaeuoaeu-ueouo",
        "attributes"=>  {
          "url" => 'http://s3-foobar',
          "fields"=>  [
            {"name"=> "foo","value"=> "bar"},
            {"name"=> "key","value"=> "uploads/oeausoea-oaeuoaeu-ueouo"}
          ]
        }
      })
    end
  end
end
