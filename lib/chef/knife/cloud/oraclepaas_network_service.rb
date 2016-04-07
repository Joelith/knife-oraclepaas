#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/oraclepaas_service'

class Chef
  class Knife
    class Cloud
      class NetworkService < OraclepaasService
  			def connection
          @connection ||= begin
            connection  = Fog::Compute::Oracle.new(
                            oracle_domain:    @identity_domain,
                            oracle_username:  @username,
                            oracle_password:  @password,
                            oracle_compute_api: Chef::Config[:knife][:oraclepaas_compute_api])
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

        def list_security_applications
        	connection.security_applications()
        end
      end
    end
  end
end
