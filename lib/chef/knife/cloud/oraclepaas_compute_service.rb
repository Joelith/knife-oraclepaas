#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/oraclepaas_service'

class Chef
  class Knife
    class Cloud
      class ComputeService < OraclepaasService
        def connection
          @connection ||= begin
            connection  = Fog::Compute::OracleCloud.new(
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

        # Security Applications

        def list_security_applications
          connection.security_applications()
        end

        def create_security_application(options = {})
          #Fog.mock!
          begin
            security_application = connection.security_applications.create(options)
          rescue Excon::Errors::BadRequest => e
            message = "Bad request: #{e.response.body}"
            ui.fatal(message)
            raise CloudExceptions::ServerCreateError, message
          rescue Fog::Errors::Error => e
            raise CloudExceptions::ServerCreateError, e.message
          end
          security_application
        end

        def get_security_application(name)
          connection.security_applications.get(name)
        end

        def delete_security_application(name) 
          begin
            secapp = get_security_application(name)
            ui.confirm("Do you really want to delete #{name}?")
            secapp.destroy
          rescue NoMethodError
           error_message = "Could not locate security application #{name}"
            ui.error(error_message)
          end
        end

        # Security Rules
        
        def list_security_rules
          connection.security_rules()
        end

        def create_security_rule(options = {})
          #Fog.mock!
          begin
            security_rule = connection.security_rules.create(options)
          rescue Excon::Errors::BadRequest => e
            message = "Bad request: #{e.response.body}"
            ui.fatal(message)
            raise CloudExceptions::ServerCreateError, message
          rescue Fog::Errors::Error => e
            raise CloudExceptions::ServerCreateError, e.message
          end
          security_rule
        end

        def get_security_rule(name)
          connection.security_rules.get(name)
        end

        def delete_security_rule(name) 
          begin
            secrule = get_security_rule(name)
            ui.confirm("Do you really want to delete #{name}?")
            secrule.destroy
          rescue NoMethodError
            error_message = "Could not locate security rule #{name}"
            ui.error(error_message)
          end
        end

        # Security Lists
        def list_security_lists
          connection.security_lists()
        end
      end
    end
  end
end
