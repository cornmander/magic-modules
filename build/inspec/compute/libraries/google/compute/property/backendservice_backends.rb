# Copyright 2018 Google Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ----------------------------------------------------------------------------
#
#     ***     AUTO GENERATED CODE    ***    AUTO GENERATED CODE     ***
#
# ----------------------------------------------------------------------------
#
#     This file is automatically generated by Magic Modules and manual
#     changes will be clobbered when the file is regenerated.
#
#     Please read more about how to change this file in README.md and
#     CONTRIBUTING.md located at the root of this package.
#
# ----------------------------------------------------------------------------

require 'google/compute/property/array'
module Google
  module Compute
    module Property
      # A class to manage data for Backends for backend_service.
      class BackendServiceBackends
        include Comparable

        attr_reader :balancing_mode
        attr_reader :capacity_scaler
        attr_reader :description
        attr_reader :group
        attr_reader :max_connections
        attr_reader :max_connections_per_instance
        attr_reader :max_rate
        attr_reader :max_rate_per_instance
        attr_reader :max_utilization


        def initialize(args = nil) 
          return nil if args.nil?
          @balancing_mode = args['balancingMode']
          @capacity_scaler = args['capacityScaler']
          @description = args['description']
          @group = Google::Compute::Property::InstanceGroupSelfLinkRef.new(args['group'])
          @max_connections = args['maxConnections']
          @max_connections_per_instance = args['maxConnectionsPerInstance']
          @max_rate = args['maxRate']
          @max_rate_per_instance = args['maxRatePerInstance']
          @max_utilization = args['maxUtilization']
        end
      end


      class BackendServiceBackendsArray < Google::Compute::Property::Array

        def self.parse(value)
          return if value.nil?
          return BackendServiceBackends.new(value) unless value.is_a?(::Array)
          value.map { |v| BackendServiceBackends.new(v) }
        end
      end
    end
  end
end