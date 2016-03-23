module S3Bunny
  class Setup
    attr_reader :setup_hash

    def initialize(setup_hash)
      @setup_hash = setup_hash
    end

    def credentials
      Aws::Credentials.new(aws_access_key_id, aws_secret_access_key)
    end

    def queues
      setup_hash.fetch(:queues).map { |q_hash| OpenStruct.new(q_hash) }
    end

    private
      def aws_access_key_id
        setup_hash.fetch(:aws_access_key_id)
      end

      def aws_secret_access_key
        setup_hash.fetch(:aws_secret_access_key)
      end
  end
end
