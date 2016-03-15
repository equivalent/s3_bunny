module S3Bunny
  class Config
    attr_writer :default_url_expires_in, :logger

    def default_url_expires_in
      @default_url_expires_in || 3600
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
