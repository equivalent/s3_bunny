require 'httparty'
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
