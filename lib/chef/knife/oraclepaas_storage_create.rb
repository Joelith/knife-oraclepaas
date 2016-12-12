#
# Author::
# Copyright::
#

require 'chef/knife/cloud/server/create_command'
require 'chef/knife/oraclepaas_helpers'
require 'chef/knife/cloud/oraclepaas_server_create_options'
require 'chef/knife/cloud/oraclepaas_storage_service'
require 'chef/knife/cloud/oraclepaas_service_options'
require 'chef/knife/cloud/exceptions'

class Chef
  class Knife
    class Cloud
      class OraclepaasStorageCreate < ServerCreateCommand
        include OraclepaasHelpers
        include OraclepaasServerCreateOptions
        include OraclepaasServiceOptions


        banner "knife oraclepaas storage create NAME"

        def create_service_instance
          StorageService.new
        end

        def before_exec_command
          super
          
          
          @create_options = {
            container_create_timeout: 30,
            container_def: {
              name: @name_args.first || config[:name]
            }
          }                   
        end

        def execute_command
          begin
            @container = service.create_container(create_options)
          rescue CloudExceptions::ServerCreateError => e
            ui.fatal(e.message)
            raise e
          end
          service.container_summary(@container, @columns_with_info)
        end

        # Setup the floating ip after server creation.
        def after_exec_command
          # Any action you want to perform post VM creation in your cloud.
          # Example say assigning floating IP to the newly created VM.
          # Make calls to "service" object if you need any information for cloud, example service.connection.addresses
          # Make call to "server" object if you want set properties on newly created VM, example server.associate_address(floating_address)

        end

        def before_bootstrap
          
        end

        def validate_params!
          super
          errors = []
          puts config
          if @name_args.first.nil? && config[:name].nil?
            errors << 'Storage Container name'
          end
          if errors.any?
            error_message = "The following required parameters are missing: #{errors.join(', ')}"
            ui.error(error_message)
            raise CloudExceptions::ValidationError, error_message
          end
        end
      end
    end
  end
end
