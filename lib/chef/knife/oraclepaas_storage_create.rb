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


        banner "knife oraclepaas storage create (options)"

        option :name,
               long:        '--name NAME',
               description: 'Name of the storage container to be created'
      
        def create_service_instance
          StorageService.new
        end

        def before_exec_command
          super
          
          
          @create_options = {
            server_create_timeout: 30,
            server_def: {
              name: locate_config_value(:name)
            }
          }                   
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
          errors = check_for_missing_config_values!(:name)
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
