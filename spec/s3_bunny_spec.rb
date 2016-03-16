require 'spec_helper'

describe S3Bunny do
  it 'has a version number' do
    expect(S3Bunny::VERSION).not_to be nil
  end

  it 'logger should be config logger' do
    expect(S3Bunny.logger).to be S3Bunny.config.logger
  end
end
