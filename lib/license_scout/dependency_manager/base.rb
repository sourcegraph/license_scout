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

require "license_scout/dependency"

module LicenseScout
  module DependencyManager
    class Base

      POSSIBLE_LICENSE_FILES = %w{
        LICENSE
        LICENSE.txt
        LICENSE.md
        LICENSE.rdoc
        License
        License.text
        License.txt
        License.md
        License.rdoc
        Licence.rdoc
        Licence.md
        MIT-LICENSE
        MIT-LICENSE.txt
        LICENSE.MIT
        LGPL-2.1
        COPYING.txt
        COPYING
        BSD_LICENSE
      }

      attr_reader :project_dir
      attr_reader :overrides
      attr_reader :environment

      def initialize(project_dir, overrides, environment)
        @project_dir = project_dir
        @overrides = overrides
        @environment = environment
      end

    end
  end
end
