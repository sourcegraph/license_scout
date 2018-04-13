#
# Copyright:: Copyright 2016, Chef Software Inc.
# License:: Apache License, Version 2.0
#
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
#

require "license_scout/dependency_manager/base"
require "license_scout/exceptions"

require "mixlib/shellout"
require "ffi_yajl"

module LicenseScout
  module DependencyManager
    class Mix < Base

      attr_reader :packaged_dependencies

      def initialize(directory)
        super(directory)

        @packaged_dependencies = {}
      end

      def name
        "elixir_mix"
      end

      def type
        "elixir"
      end

      def signature
        "mix.lock file"
      end

      def install_command
        "mix deps.get"
      end

      def detected?
        File.exist?(mix_lock_path)
      end

      def dependencies
        parse_packaged_dependencies

        # Some dependencies are obtained via 'pkg' identifier of rebar. These
        # dependencies include their version in the rebar.lock file. Here we
        # parse the rebar.lock and remember all the versions we find.
        packaged_dependencies.map do |dep_name, dep_version|
          dep_path = Dir.glob(File.join(directory, "**", "deps", dep_name)).first

          dependency = new_dependency(dep_name, dep_version, dep_path)

          Array(hex_info(dep_name).dig("meta", "licenses")).each do |license|
            dependency.add_license(license, "https://hex.pm/api/packages/#{dep_name}")
          end

          dependency
        end.compact
      end

      private

      def parse_packaged_dependencies
        mix_lock_to_json_path = File.expand_path("../../../bin/mix_lock_json", File.dirname(__FILE__))
        s = Mixlib::ShellOut.new("#{LicenseScout::Config.escript_bin} #{mix_lock_to_json_path} #{mix_lock_path}", environment: LicenseScout::Config.environment)
        s.run_command
        s.error!

        mix_lock_content = FFI_Yajl::Parser.parse(s.stdout)

        mix_lock_content.each do |dep|
          name = dep.keys.first
          version = dep.values.first

          @packaged_dependencies[name] = version
        end
      end

      def mix_lock_path
        File.join(directory, "mix.lock")
      end

      def hex_info(package_name)
        FFI_Yajl::Parser.parse(open("https://hex.pm/api/packages/#{package_name}").read)
      rescue OpenURI::HTTPError
        LicenseScout::Log.debug("[elixir] Unable to download hex.pm info for #{package_name}")
        {}
      end
    end
  end
end
