module S3Bunny
  module JSONAPIHelper
    def self.as_json(aws_resource)
      {
        'type' => 'aws_s3_presigned_posts',
        'id'   => aws_resource.fields.fetch('key'),
        'attributes' => {
          'fields' => aws_resource.fields.map do |key, value|
            { "name" => key, "value" => value }
          end
        }
      }
    end
  end
end
