#
# Author:: Brandon Adams <brandon.adams@me.com>
# Author:: Noah Kantrowitz <noah@coderanger.net>
# Author:: Isac Petruzzi <isac@artsymail.com>
#
# Copyright 2012-2013, Brandon Adams and other contributors
# Copyright 2013, Balanced, Inc.
# Copyright 2016, Artsy, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


class Citadel
  module S3
    extend self

    def get(bucket, key, credentials, region)
      require 'json'
      require 'aws-sdk'

      s3 = Aws::S3::Client.new(region: region, credentials: credentials)

      begin
        meta = s3.head_object bucket: bucket, key: key
      rescue Aws::S3::Errors::NoSuchKey
        raise "Could not locate #{key} in #{bucket}. Aborting."
      end

      begin
        kms_key_id = JSON.parse(meta[:metadata]["x-amz-matdesc"])["kms_cmk_id"]
      rescue
        raise "Could not load kms_cmk_id"
      end

      kms = Aws::KMS::Client.new(region: region, credentials: credentials)
      s3e = Aws::S3::Encryption::Client.new(kms_key_id: kms_key_id, kms_client: kms, client: s3)

      response = s3e.get_object bucket: bucket, key: key
      payload = response.data.body.read

      begin
        JSON.parse payload
      rescue JSON::ParserError
        payload
      end
    end
  end
end
