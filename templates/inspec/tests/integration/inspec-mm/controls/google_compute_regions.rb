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

title 'Test GCP regions plural resource.'

control 'gcp-regions-1.0' do
  impact 1.0
  title 'GCP Region plural test'

  resource = google_compute_regions(project: attribute('project_name'))

  describe resource do
    it { should exist }
    its('names') { should include 'us-west1' }
    its('names') { should include 'us-east4' }
  end
end