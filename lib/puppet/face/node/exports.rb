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
    arguments "<none>"

    option "--highlight" do
      summary "Enable colorized output"
      default_to { false }
    end

    option "--resources RESOURCE" do
      summary "Filter the query to just a particular resource"
      default_to { '' }
    end


    description <<-'EOT'
      This is a simple wrapper to connect to puppetdb for exported records
    EOT
    notes <<-'NOTES'
      Directly connects to the puppetdb server using your local certificate
    NOTES
    examples <<-'EOT'
      List all exported resources:

      $ puppet node export

      List file exported resources:

      $ puppet node exports file
    EOT

    when_invoked do |options|
      output = [ {'Name' => 'Exports'} ]
      connection = Puppet::Network::HttpPool.http_instance(Puppet::Util::Puppetdb.server,'8081')
      query = ["and",["=","exported",true]]
      if options[:resources]
        types = options[:resources].split(',').map{|resource| ['=','type',resource] }
        query = query.concat(types)
      end
      json_query = URI.escape(query.to_json)
      unless filtered = PSON.load(connection.request_get("/v3/resources/?query=#{json_query}", {"Accept" => 'application/json'}).body)
        raise "Error parsing json output of puppet search #{filtered}"
      end
      output << filtered.map { |node| Hash[node['certname'] => "#{node['type'].capitalize}[#{node['title']}]"]}
      output.flatten
    end

    when_rendering :console do |output,options|
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
          Puppet.debug("#{options.inspect}")
          if n.odd?
            (options[:highlight] && highlight[ :hwhite,format % [ node_name, exports ] ] || format % [ node_name, exports ])
          else
            (options[:highlight] && highlight[ :white,format % [ node_name, exports ] ] || format % [ node_name, exports ])
          end
        end.join
      end
    end
  end
end
