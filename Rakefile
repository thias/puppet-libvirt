#   Copyright 2013 Brainsware
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'rspec-system/rake_task'

def version
	File.open('Modulefile').each do |line|
		return line.split("'")[1] if line =~ /\bversion\b/
	end
end

desc "Create a releasable artifact along with signed tags."
task :release do
	sh "git tag -s #{version} -m 't&r #{version}'"
	sh "git checkout #{version}"
	sh "puppet module build ."
end

