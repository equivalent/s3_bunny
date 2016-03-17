# example of how to pull url via paperclip

If using gem [paperclip](https://github.com/thoughtbot/paperclip) `> 3.1.4` you can do something
like this to pull file from url

```ruby
class User < ActiveRecord::Base
  attr_reader :avatar_remote_url
  has_attached_file :avatar

  def avatar_remote_url=(url_value)
    self.avatar = URI.parse(url_value)
    # Assuming url_value is http://example.com/photos/face.png
    # avatar_file_name == "face.png"
    # avatar_content_type == "image/png"
    @avatar_remote_url = url_value
  end
end

user = User.new
user.avatar_remote_url = 'http://example.com/photos/face.png'
user.save!
```

> source https://github.com/thoughtbot/paperclip/wiki/Attachment-downloaded-from-a-URL

The problem is that S3 url is sending binary mime type `binary/octet-stream` and therefore 
if you are implementing validations on your uploads:


```
class User < ActiveRecord::Base
  # ...
  validates_attachment_content_type :avatar, :content_type =>  ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  # ...
end
```

...you'll get error:

```
Validation failed: File has contents that are not what they are
reported to be, File is invalid, File content type is invalid
```

One solution is to skip validations in this context:

```ruby
#...
medium.save!(validate: false)  # will skip validations
```

...but that's not secure.

I'm recommending to download the file to your `/tmp/` folder as a temp
file, and upload it via Paperclip

Install gem `httparty`

```
# Gemfile
# ...
gem 'httparty'
# ...
```

Run `bundle install`


Next create new file `./lib/s3_bunny_helper.rb`

```
require 'httparty'      # gem
module S3Bunny
  module Helper
    def pull_asset(url:, destination:)
      File.open(destination, "wb") do |f| 
        f.binmode
        f.write HTTParty.get(url).parsed_response
        f.close
      end
    end
  end
end
```

And now you can do something like:

```ruby
user = User.new
require Rails.root.join('lib', 's3_bunny_helper')

S3Bunny::Helper.pull_asset(url: "http://s3....../bbuesubeueueue", destination: "/tmp/my-file.jpg")

user.avatar = File.open("/tmp/my-file.jpg")
user.save!
```

If you are looking for something more sophisticated that will
take care of deleting Temp file from system I recommending solution we
use:


```ruby
require 'httparty'      # gem
require 'securerandom'  # standard Ruby lib
require 'pathname'      # standard Ruby lib
require 'tempfile'      # standard Ruby lib

module S3Bunny
  module Helper
    def self.pull_file(url:, original_filename:)
      _generated_name =
Pathname.new("#{SecureRandom.hex(10)}_#{original_filename}")
      extension     = _generated_name.extname.to_s
      tmp_file_name = _generated_name.basename(extension).to_s

      file = Tempfile.new([tmp_file_name, extension])
      file.binmode
      file.write(HTTParty.get(url).parsed_response)
      file.close

      yield file.open
    ensure
      file.try(:unlink) #delete temp file
    end
  end
end
```


```ruby
require Rails.root.join('lib', 's3_bunny_helper')

url = "https://s3url ...."
original_filename = "original_file_name_from_s3_bunny.jpg"

S3Bunny::Helper.pull_file(url: url, original_filename: original_filename) do |tmp_file|
  medium.file = tmp_file
  medium.save!
end
```

