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

TODO: Write usage instructions here



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

