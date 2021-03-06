# Copyright 2017 Google Inc.
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

require 'net/http'
require 'singleton'

module Google
  module Codegen
    # A helper class to block access to the network during tests, while
    # providing a whitelist escape for the Google::*::Network::* classes to test
    # themselves, also without accessing the network.
    class NetworkBlocker
      include Singleton

      ALLOWED_TEST_URI = URI.parse('https://www.unreachable-test-host.com/blah')

      attr_reader :allowed_test_hosts
      attr_reader :allowed_request
      attr_reader :canned_response

      def initialize
        @allowed_test_hosts = [
          { host: ALLOWED_TEST_URI.host, port: ALLOWED_TEST_URI.port }
        ]
      end

      def allow_get(uri, code, type, body)
        @allowed_request = { uri: uri }
        @canned_response = response(uri, code, type, body)
      end

      def allow_delete(uri)
        @allowed_request = { uri: uri }
        @canned_response = Net::HTTPNoContent.new(1.0, 204, 'No Content')
      end

      def allow_post(args)
        @allowed_request = {
          uri: args[:uri_in],
          type: args[:type_in],
          body: args[:body_in]
        }
        @canned_response = response(args[:uri_out], args[:code],
                                    args[:type_out], args[:body_out])
      end

      def allow_put(args)
        allow_post(args) # PUT uses same interface as POST
      end

      def deny(uri, code = 404)
        case code
        when 404
          @allowed_request = { uri: uri }
          @canned_response = Net::HTTPNotFound.new(1.0, 404, 'Not Found')
        else
          raise ArgumentError, "Unknown error code #{code}"
        end
      end

      private

      def response(uri, code, type, body)
        response = Net::HTTPOK.new(1.0, code, 'OK')
        response.uri = uri
        response.content_type = type
        response.body = body
        response.instance_variable_set(:@read, true)
        response
      end
    end
  end
end

# Monkey patching of core Net::HTTP components to trap and block all network
# access, except to return canned responses when using the magic
# ALLOWED_TEST_URI URL.
module Net
  class HTTP
    define_method(:initialize) do |*args|
      blocker = Google::Codegen::NetworkBlocker.instance
      unless blocker.allowed_test_hosts.map { |h| h[:host] }.include?(args[0])
        message = [self, __method__, ':',
                   'Network traffic is blocked during tests', ':',
                   args[0]].join(' ')
        if ENV['RSPEC_DEBUG']
          module_dir = File.expand_path('..', File.dirname(__FILE__))
          puts [message,
                caller.select { |c| c.include?(module_dir) }.join("\n")
                      .gsub(/^/, '  ')].join("\n")
        end
        raise IOError, message
      end
    end

    instance_methods.each do |m|
      unless %i[get copy delete finish get get2 head head2 lock mkcol move
                options patch post post2 propfind proppatch put put2 request
                request_get request_head request_post request_put send
                send_request start trace unlock].include?(m)
        next
      end
      define_method(m) do |*args|
        request_allowed = true

        blocker = Google::Codegen::NetworkBlocker.instance
        if !args.empty? && args[0].is_a?(Net::HTTPGenericRequest)
          allow_terms = blocker.allowed_request
          allow_terms.each_key do |key|
            case key
            when :uri
              request_allowed &&= args[0].uri == allow_terms[:uri]
            when :type
              request_allowed &&= args[0].content_type == allow_terms[:type]
            when :body
              request_allowed &&= args[0].body == allow_terms[:body]
            end
          end
        end

        return blocker.canned_response if request_allowed

        raise IOError, [self, __method__, ':',
                        'Network traffic is blocked during tests', ':',
                        args[0]].join(' ')
      end
    end
  end
end
