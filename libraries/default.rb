#
# Author:: Noah Kantrowitz <noah@coderanger.net>
# Author:: Isac Petruzzi <isac@artsymail.com>
#
# Copyright 2013, Balanced, Inc.
# Copyright 2016, Artsy, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Citadel
  attr_reader :bucket, :region, :credentials

  def initialize(node, bucket=nil)
    require 'aws-sdk-resources'

    @node = node
    @bucket = bucket || node['citadel']['bucket']
    @region = node['citadel']['region']

    if node['citadel']['access_key_id'] && node['citadel']['secret_access_key']
      # Manually specified credentials
      @credentials = Aws::Credentials.new(node['citadel']['access_key_id'], node['citadel']['secret_access_key'])
    else
      # IAM credentials
      @credentials = Aws::InstanceProfileCredentials.new
    end
  end

  def [](key)
    Chef::Log.debug("citadel: Retrieving #{@bucket}/#{key}")
    Citadel::S3.get(@bucket, key, @credentials, @region)
  end

  # Helper module for the DSL extension
  module ChefDSL
    def citadel(bucket=nil)
      Citadel.new(node, bucket)
    end
  end
end

# Patch our DSL extension into Chef
class Chef
  class Recipe
    include Citadel::ChefDSL
  end

  class Resource
    include Citadel::ChefDSL
  end

  class Provider
    include Citadel::ChefDSL
  end
end

