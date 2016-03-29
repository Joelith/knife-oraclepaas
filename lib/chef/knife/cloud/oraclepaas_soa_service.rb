#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/oraclepaas_service'

class Chef
  class Knife
    class Cloud
      class SoaService < OraclepaasService

        def connection
          @connection ||= begin
            connection  = Fog::Oracle::SOA.new(
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
      end
    end
  end
end
