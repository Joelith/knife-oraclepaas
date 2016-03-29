#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/oraclepaas_service'

class Chef
  class Knife
    class Cloud
      class StorageService < OraclepaasService

        def connection
          @connection ||= begin
            connection  = Fog::Storage::Oracle.new(
                            oracle_domain:    @identity_domain,
                            oracle_username:  @username,
                            oracle_password:  @password)
                          rescue Excon::Errors::Unauthorized => e
                            error_message = "Connection failure, please check your username and password."
                            ui.fatal(error_message)
                            raise CloudExceptions::ServiceConnectionError, "#{e.message}. #{error_message}"
                          rescue Excon::Errors::SocketError => e
                            error_message = "Connection failure, please check your authentication URL."
                            ui.fatal(error_message)
                            raise CloudExceptions::ServiceConnectionError, "#{e.message}. #{error_message}"
                          end
        end

        def list_instances
          connection.containers()
        end

        def create_server(options={})
          server = connection.containers.create(options[:server_def])
        end

        def server_summary(server, _columns_with_info = nil)
          msg_pair('Name', server.name)
        end
      end
    end
  end
end
