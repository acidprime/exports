require 'puppet/face'
require 'puppet/util/terminal'
require 'puppet/util/colors'
require 'puppet/network/http_pool'
require 'uri'
require 'json'

Puppet::Face.define(:node, '0.0.1') do
  extend Puppet::Util::Colors
  action :exports do
    summary "Return the exports of nodes from puppetdb"
    arguments "node"

    description <<-'EOT'
      stuff
    EOT
    notes <<-'NOTES'
      things
    NOTES
    examples <<-'EOT'
      Compare host catalogs:

      $ puppet node exports
    EOT

    when_invoked do |options|
      output = [ {'Name' => 'Exports'} ]
      connection = Puppet::Network::HttpPool.http_instance(Puppet[:server],'8081')
      json_query = URI.escape(["=","exported",true].to_json)
      unless filtered = PSON.load(connection.request_get("/v2/resources/?query=#{json_query}", {"Accept" => 'application/json'}).body)
        raise "Error parsing json output of puppet search #{filtered}"
      end
      Puppet.debug("FILTERED: #{filtered}")
      output << filtered.map { |node| Hash[node['certname'] => "#{node['type'].capitalize}[#{node['title']}]"]}
      output.flatten
    end

    when_rendering :console do |output|
      if output.empty?
        Puppet.notice("No exported records found")
      end
      padding = '  '
      headers = {
        'node_name'   => 'Name',
        'exports'     => 'Exports',
      }

      min_widths = Hash[ *headers.map { |k,v| [k, v.length] }.flatten ]
      min_widths['node_name'] = min_widths['exports'] = 40

      min_width = min_widths.inject(0) { |sum,pair| sum += pair.last } + (padding.length * (headers.length - 1))

      terminal_width = [Puppet::Util::Terminal.width, min_width].max

      highlight = proc do |color,s|
        c = colorize(color, s)
        c
      end
      n = 0
      output.collect do |results|

        columns = results.inject(min_widths) do |node_name,exports|
          {
            'node_name'   => node_name.length,
            'exports' => exports.length,
          }
        end

        flex_width = terminal_width - columns['node_name'] - columns['exports'] - (padding.length * (headers.length - 1))

        format = %w{node_name exports}.map do |k|
          "%-#{ [ columns[k], min_widths[k] ].max }s"
        end.join(padding)
        results.map do |node_name,exports|
          n += 1
          if n.odd?
            highlight[ :hwhite,format % [ node_name, exports ] ]
          else
            highlight[ :white,format % [ node_name, exports ] ]
          end
        end.join
      end
    end
  end
end
