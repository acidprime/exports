#!/opt/puppetlabs/puppet/bin/ruby
#
# Puppet Task to purge nodes
# This can only be run against the Puppet Master.
#
# Parameters:
#   * agent_certnames - A comma-separated list of agent certificate names.
#
require 'puppet'
require 'open3'

Puppet.initialize_settings

unless Puppet[:server] == Puppet[:certname]
  puts 'This task can only be run against the Master (of Masters)'
  exit 1
end

def exports(resources)
  command = "/opt/puppetlabs/puppet/bin/puppet node exports --json"

  unless resources.to_s.empty?
    command << " --resources \"#{resources}\""
  end

  stdout, stderr, status = Open3.capture3(command)
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
