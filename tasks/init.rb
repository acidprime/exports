#!/opt/puppetlabs/puppet/bin/ruby
#
# Puppet task for querying puppetdb exports
# This can only be run against the Puppet Master.
#
# Parameters:
#   * resources - Filter the query to just a particular resource
#
require 'puppet'
require 'open3'

Puppet.initialize_settings

def exports(resources)
  resources_flag = ''

  unless resources.to_s.empty?
    resources_flag = '--resources' 
  end

  stdout, stderr, status = Open3.capture3('/opt/puppetlabs/puppet/bin/puppet','node','exports', resources_flag, resources)
  {
    stdout: stdout.strip,
    stderr: stderr.strip,
    exit_code: status.exitstatus,
  }    
end

params = JSON.parse(STDIN.read)
resources = params['resources']

output = exports(resources)
if output[:exit_code].zero?
    # Assuming that if the results is just the table header the results are empty.
    if output[:stdout].length == 49
      puts 'No Results Found.'
    else
      puts output[:stdout]
    end
else
  puts "There was a problem: #{output[:stderr]}"
end
