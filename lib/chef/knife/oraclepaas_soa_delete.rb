require 'chef/knife/cloud/server/delete_command'
require 'chef/knife/oraclepaas_helpers'
require 'chef/knife/cloud/oraclepaas_soa_service'

class Chef
  class Knife
    class Cloud
      class OraclepaasSoaDelete < ServerDeleteCommand
        include OraclepaasHelpers

        banner "knife oraclepaas soa delete (options)"

        option :dba_name,
             long:        '--dba_name NAME',
             description: 'Name of the DB Administrator (to be able to delete the schemas)'
        option :dba_password,
             long:        '--dba_password PASSWORD',
             description: 'The password for the administrator'
        option :force_delete,
             long:        '--force_delete',
             description: 'Whether we should force delete the instance, even if schemas can\'t be deleted'
        option :skip_backup,
             long:        '--skip_backup',
             description: 'Flag that specifies whether you want to skip backing up the service instance before deleting it'
        
       	def create_service_instance
          SoaService.new
        end

        def execute_command
          @name_args.each do |service_name|
            service.delete_server({
            	:service_name => service_name, 
            	:dba_name 		=> locate_config_value(:dba_name), 
            	:dba_password => locate_config_value(:dba_password),
              :force_delete => locate_config_value(:force_delete),
              :skip_backup  => locate_config_value(:force_delete)
            })
            #delete_from_chef(service_name)
            puts "Instance #{service_name} requested to be deleted\n"
          end
        end

        def validate_params!
          super
          errors = check_for_missing_config_values!(:dba_name, :dba_password, :oraclepaas_username, :oraclepaas_password)
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
