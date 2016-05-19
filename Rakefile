require 'rake'
require 'tempfile'
require 'json'
require 'aws-sdk'

namespace :citadel do

  desc "Create a plaintext key"
  task :create_plain, [:key] do |t, args|
    ensure_editor!
    bucket = bucket_env!
    key = args[:key]

    s3 = Aws::S3::Client.new()

    begin
      response = s3.get_object bucket: bucket, key: key
      if response.successful?
        puts "Key #{key} already exists in #{bucket}. Aborting."
        exit 1
      end
    rescue Aws::S3::Errors::NoSuchKey
    end

    t = Tempfile.new('citadel')
    system(ENV['EDITOR'] + ' ' + t.path)
    save_key_to_bucket! s3, bucket, key, File.open(t.path).read
    t.unlink
    puts "Success"
  end

  desc "Create an encrypted key"
  task :create_secure, [:key] do |t, args|
    ensure_editor!
    bucket = bucket_env!
    key = args[:key]

    kms = Aws::KMS::Client.new
    s3 = Aws::S3::Encryption::Client.new(kms_key_id: key_id_env!, kms_client: kms)

    begin
      response = s3.get_object bucket: bucket, key: key
      if response.successful?
        puts "Key #{key} already exists in #{bucket}. Aborting."
        exit 1
      end
    rescue Aws::S3::Errors::NoSuchKey
    end

    t = Tempfile.new('citadel')
    system(ENV['EDITOR'] + ' ' + t.path)
    save_key_to_bucket! s3, bucket, key, File.open(t.path).read
    t.unlink
    puts "Success"
  end

  desc "Edit a key"
  task :edit, [:key] do |t, args|
    ensure_editor!
    bucket = bucket_env!
    key = args[:key]

    s3 = Aws::S3::Client.new

    begin
      meta = s3.head_object bucket: bucket, key: key
    rescue Aws::S3::Errors::NoSuchKey
      puts "Could not locate #{key} in #{bucket}. Aborting."
      exit 1
    end

    if meta[:metadata]["x-amz-matdesc"].nil?
      s3_client = s3
    else
      kms = Aws::KMS::Client.new
      s3_client = Aws::S3::Encryption::Client.new(kms_key_id: key_id_env!, kms_client: kms)
    end

    response = s3_client.get_object bucket: bucket, key: key

    t = Tempfile.new('citadel')
    t.write(response.data.body.read)
    t.close
    system(ENV['EDITOR'] + ' ' + t.path)
    save_key_to_bucket! s3_client, bucket, key, File.open(t.path).read
    t.unlink
    puts "Success"
  end

  desc "Get a key"
  task :get, [:key] do |t, args|
    bucket = bucket_env!
    key = args[:key]

    s3 = Aws::S3::Client.new

    begin
      meta = s3.head_object bucket: bucket, key: key
    rescue Aws::S3::Errors::NoSuchKey
      puts "Could not locate #{key} in #{bucket}. Aborting."
      exit 1
    end

    if meta[:metadata]["x-amz-matdesc"].nil?
      s3_client = s3
    else
      kms_key_id = JSON.parse(meta[:metadata]["x-amz-matdesc"])["kms_cmk_id"]
      kms = Aws::KMS::Client.new
      s3_client = Aws::S3::Encryption::Client.new(kms_key_id: kms_key_id, kms_client: kms, client: s3)
    end

    response = s3_client.get_object bucket: bucket, key: key

    puts response.data.body.read

  end

  desc "Delete a key"
  task :delete, [:key] do |t, args|
    bucket = bucket_env!
    key = args[:key]

    s3 = Aws::S3::Client.new

    begin
      response = s3.get_object bucket: bucket, key: key
    rescue Aws::S3::Errors::NoSuchKey
      puts "Could not locate #{key} in #{bucket}. Aborting."
      exit 1
    end

    s3.delete_object bucket: bucket, key: key
    puts "Deleted #{key} from #{bucket}"

  end

  def save_key_to_bucket!(s3, bucket, key, payload)
    begin
      JSON.parse payload
      puts "Saving #{key} to #{bucket}"
      s3.put_object bucket: bucket, key: key, body: payload
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

  def key_id_env!
    if ENV['CITADEL_KEY_ID'].nil?
      puts "Set CITADEL_KEY_ID."
      exit 1
    end
    ENV['CITADEL_KEY_ID']
  end

  def ensure_editor!
    if ENV['EDITOR'].nil?
      puts "Set EDITOR."
      exit 1
    end
  end

end
