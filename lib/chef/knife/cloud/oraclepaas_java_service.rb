#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/oraclepaas_service'

class Chef
  class Knife
    class Cloud
      class JavaService < OraclepaasService

        def connection
          @connection ||= begin
            connection  = Fog::OracleCloud::Java.new(
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
        
        def delete_server(options = {})
          begin
            server = get_server(options[:service_name])
            server.dba_name = options[:dba_name]
            server.dba_password = options[:dba_password]
            server.force_delete = options[:force_delete]
            msg_pair("Instance Name", server.service_name)

            puts "\n"
            ui.confirm("Do you really want to delete this server")

            # delete the server
            server.destroy
          rescue NoMethodError
            error_message = "Could not locate instance '#{options[:service_name]}'."
            ui.error(error_message)
            raise CloudExceptions::ServerDeleteError, error_message
          rescue Excon::Errors::BadRequest => e
            handle_excon_exception(CloudExceptions::ServerDeleteError, e)
          end
        end
      end
    end
  end
end
