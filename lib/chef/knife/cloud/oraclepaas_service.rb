#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/fog/service'
require 'fog/oraclecloud'


class Chef
  class Knife
    class Cloud
      class OraclepaasService < FogService

        def initialize(options = {})
          super(options)

          @username        = Chef::Config[:knife][:oraclepaas_username]
          @password        = Chef::Config[:knife][:oraclepaas_password]
          @identity_domain = Chef::Config[:knife][:oraclepaas_domain]
        end
        
        def list_instances
          connection.instances()
        end

        def get_server(service_name)
          connection.instances.get(service_name)
        rescue Excon::Errors::BadRequest => e
          handle_excon_exception(CloudExceptions::KnifeCloudError, e)
        end

        def create_server(options = {})
          #Fog.mock!
          begin
            add_custom_attributes(options[:server_def])
            server = connection.instances.create(options[:server_def])
          rescue Excon::Errors::BadRequest => e
            message = "Bad request: #{e.response.body}"
            ui.fatal(message)
            raise CloudExceptions::ServerCreateError, message
          rescue Fog::Errors::Error => e
            raise CloudExceptions::ServerCreateError, e.message
          end
          #Fog.unmock!
          print "\n#{ui.color("Waiting for server [wait time = #{options[:server_create_timeout]} seconds, delay = 60 seconds]", :magenta)}"

          # wait for it to be ready to do stuff
          server.wait_for(Integer(options[:server_create_timeout]), 60) { print "."; ready? }
          puts("\n")
          server
        end

        
      end
    end
  end
end
