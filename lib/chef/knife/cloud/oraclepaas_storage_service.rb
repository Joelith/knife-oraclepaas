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

        def get_container(name)
          connection.containers.get(name)
        rescue Excon::Errors::BadRequest => e
          handle_excon_exception(CloudExceptions::KnifeCloudError, e)
        end


        def list_containers
          connection.containers()
        end

        def create_container(options={})
          container = connection.containers.create(options[:container_def])
        end

        def container_summary(container, _columns_with_info = nil)
          msg_pair('Name', container.name)
        end

        def delete_container(name)
          begin
            container = get_container(name)
            msg_pair("Storage Name", container.name)

            puts "\n"
            ui.confirm("Do you really want to delete this storage container")

            # delete the container
            container.destroy
          rescue NoMethodError
            error_message = "Could not locate storage container '#{name}'."
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
