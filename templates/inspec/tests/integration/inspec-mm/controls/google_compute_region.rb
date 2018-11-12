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

require 'vcr_config'

title 'GCP single region test'

control 'gcp-region-1.0' do
  impact 1.0
  title 'GCP region resource test'

  VCR.use_cassette('gcp-region') do
    describe google_compute_region(project: attribute('project_name'), name: attribute('region')) do
      it { should exist }
    end
  end
end