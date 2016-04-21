require 'chef/knife/cloud/server/delete_command'
require 'chef/knife/oraclepaas_helpers'
require 'chef/knife/cloud/oraclepaas_storage_service'

class Chef
  class Knife
    class Cloud
      class OraclepaasStorageDelete < ServerDeleteCommand
        include OraclepaasHelpers

        banner "knife oraclepaas storage delete (options)"

       	def create_service_instance
          StorageService.new
        end

        def execute_command
          @name_args.each do |name|
            service.delete_container(name)
            puts "Storage container #{name} requested to be deleted\n"
          end
        end

        def validate_params!
          super
          errors = check_for_missing_config_values!(:oraclepaas_domain, :oraclepaas_username, :oraclepaas_password)
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
