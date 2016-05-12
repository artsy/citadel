require 'rake'
require 'tempfile'
require 'json'
require 'aws-sdk'

namespace :citadel do

  desc "Create a key"
  task :create, [:key] do |t, args|
    bucket = bucket_env!
    key = args[:key]

    begin
      response = Aws::S3::Client.new.get_object bucket: bucket, key: key
      if response.successful?
        puts "Key #{key} already exists in #{bucket}. Aborting."
        exit 1
      end
    rescue Aws::S3::Errors::NoSuchKey
    end

    t = Tempfile.new('citadel')
    system(ENV['EDITOR'] + ' ' + t.path)
    save_key_to_bucket! bucket, key, File.open(t.path).read
    t.unlink
  end

  desc "Edit a key"
  task :edit, [:key] do |t, args|
    bucket = bucket_env!
    key = args[:key]

    response = Aws::S3::Client.new.get_object bucket: bucket, key: key
    if !response.successful?
      puts "Could not locate #{key} in #{bucket}. Aborting."
      exit 1
    end

    t = Tempfile.new('citadel')
    t.write(response.data.body.read)
    t.close
    system(ENV['EDITOR'] + ' ' + t.path)
    save_key_to_bucket! bucket, key, File.open(t.path).read
    t.unlink
  end

  def save_key_to_bucket!(bucket, key, payload)
    begin
      JSON.parse payload
      puts "Saving #{key} to #{bucket}"
      Aws::S3::Client.new.put_object bucket: bucket, key: key, body: payload
      puts "Success!"
      exit 0
    rescue JSON::ParserError
      puts "Invalid JSON.  Aborting."
      exit 1
    end
  end

  def bucket_env!
    if ENV['CITADEL_BUCKET'].nil?
      puts "Set CITADEL_BUCKET."
      exit 1
    end
    ENV['CITADEL_BUCKET']
  end

end
