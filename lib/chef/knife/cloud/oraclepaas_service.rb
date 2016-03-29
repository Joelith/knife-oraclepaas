#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/fog/service'

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

        def connection
          #@connection ||= begin
          #  connection  = Fog::Oracle::Java.new(
          #                  oracle_domain:    @identity_domain,
          #                  oracle_username:  @username,
          #                  oracle_password:  @password)
          #                rescue Excon::Errors::Unauthorized => e
          #                  error_message = "Connection failure, please check your username and password."
          #                  ui.fatal(error_message)
          #                  raise CloudExceptions::ServiceConnectionError, "#{e.message}. #{error_message}"
          #                rescue Excon::Errors::SocketError => e
          #                  error_message = "Connection failure, please check your authentication URL."
          #                  ui.fatal(error_message)
          #                  raise CloudExceptions::ServiceConnectionError, "#{e.message}. #{error_message}"
          #                end
        end
        
        def list_instances
          connection.instances()
        end

        def get_server(instance_id)
          connection.instances.get(instance_id)
        rescue Excon::Errors::BadRequest => e
          handle_excon_exception(CloudExceptions::KnifeCloudError, e)
        end

        def create_server(options = {})
          Fog.mock!
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
