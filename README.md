# S3Bunny

...work in progress

## Installation

Add this line to your application's Gemfile:

```ruby
gem 's3_bunny'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install s3_bunny

## Usage

1. Create a new S3 bucket / edit S3 bucket (we recommend separate bucket for
   every enviroment development, qa, staging, production ...)
2. Edit bucket CORS and allow origin (in our case `http://localhost:3000`)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <CORSRule>
        <AllowedOrigin>http://localhost:3000</AllowedOrigin>
        <AllowedMethod>GET</AllowedMethod>
        <AllowedMethod>POST</AllowedMethod>
        <AllowedMethod>PUT</AllowedMethod>
        <AllowedHeader>*</AllowedHeader>
    </CORSRule>
</CORSConfiguration>
```

3. create SQS que and allow this S3 Bucket to write to it + your
   application to read from it


```
{
  "Version": "2008-10-17",
  "Id": "example-ID",
  "Statement": [
    {
      "Sid": "example-statement-ID",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "SQS:SendMessage",
      "Resource":
"arn:aws:sqs:eu-west-1:666666666666:myappcom-ireland-s3bunny-uppload-development",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn":
"arn:aws:s3:*:*:myapp.com-browser-uploads-development"
        }
      }
    },
    {
      "Sid": "Sid1457107544131",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::666666666666:user/myapp_user"
      },
      "Action": "SQS:*",
      "Resource":
"arn:aws:sqs:eu-west-1:666666666666:myappcom-ireland-s3bunny-uppload-development"
    }
  ]
}
```

4. make sure your application AWS AMI user (`myapp_user`) has permission to edit/read/delete this Queue. For debugging purpose for now you can choose `SQSFullAccess`  and then change it aproprietly 

5. 


## Easter Eggs

#### JSON API json helper of Aws::S3::PresignedPost


```ruby
require 's3_bunny/jsonapi_helper'
class ProvisionalUploadsController < ApplicationController
  def new
    @presigned_post =  S3Bunny::BrowserUpload
      .new(region: region, credentials: credentials, bucket_name: bucket_name)
      .tap { |pp| # ... }
       # ... and so on

    respond_to do |format|
      format.html { render 'new' }  # render form with @presigned_post
      format.json { render json: S3Bunny::JSONAPIHelper.as_json(@presigned_post) } # json fields
    end
  end
end
```

```json
{
  "type":"aws_s3_presigned_posts",
  "id":"uploads/4ada3f37-4603-4844-b348-11dcddc5f786",
  "attributes":{
    "fields":[
       "url":"https://s3-eu-west....."
       {"name":"key","value":"uploads/4ada3f37-4603-4844-b348-11dcddc5f786"},
       {"name":"success_action_status","value":"201"},
       {"name":"acl","value":"public-read"},
       # ...
    ]
  }
}
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/s3_bunny. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

