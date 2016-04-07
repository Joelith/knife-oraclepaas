#
# Author::
# Copyright::
#

require 'chef/knife/cloud/server/create_command'
require 'chef/knife/oraclepaas_helpers'
require 'chef/knife/cloud/oraclepaas_compute_service'
require 'chef/knife/cloud/oraclepaas_service_options'
require 'chef/knife/cloud/exceptions'

class Chef
  class Knife
    class Cloud
      class OraclepaasSecruleCreate < Command
        include OraclepaasHelpers
        include OraclepaasServiceOptions

        banner "knife oraclepaas secrule create (options)"

        option :name,
               long:        '--name NAME',
               description: 'Name of the security rule. Can only contain alphanumeric characters, hyphens, underscores and periods. Your identity domain and username will be prepended automatically.'
        option :src_list,
               long:        '--src_list LIST',
               description: 'Name of the source security list or security IP list to use'
        option :dst_list,
               long:        '--dst_list LIST',
               description: 'Name of the destination security list or security IP list to use'
        option :application,
               long:        '--application APP',
               description: 'The name of the security application to use'
        option :action,
               long:        '--action ACTION',
               description: 'Either PERMIT or DENY'
        option :description,
               long:        '--description DESCRIPTION',
               description: 'A description of the security rule'
        option :disabled,
               long:        '--disabled',
               description: 'Indicates whether the security is disabled or enabled'

				 def create_service_instance     
          ComputeService.new
        end    

  			def before_exec_command
          super
          src_list = locate_config_value(:src_list)
          if src_list == 'public-internet'
            src_list = 'seciplist:/oracle/public/public-internet'
          end
          dst_list = locate_config_value(:dst_list)
          if dst_list == 'public-internet'
            dst_list = 'seciplist:/oracle/public/public-internet'
          end
          application = locate_config_value(:application)
          if application[0,1] != '/'
            # They didn't provide the container name. Assume it's their container (and not /oracle/public)
            application = "/Compute-#{locate_config_value(:oraclepaas_domain)}/#{locate_config_value(:oraclepaas_username)}/#{application}"
          end
         	@create_options = {
         		name: "/Compute-#{locate_config_value(:oraclepaas_domain)}/#{locate_config_value(:oraclepaas_username)}/#{locate_config_value(:name)}",
         		src_list: src_list,
         		dst_list: dst_list,
         		application: application,
         		action: locate_config_value(:action),
            description: locate_config_value(:description),
            disabled: locate_config_value(:disabled)
         	}
          @create_options.delete_if { |k, v| v.nil? }                
        end

        def execute_command
        	begin
        		@secrule = service.create_security_rule(@create_options)
        	rescue CloudExceptions::ServerCreateError => e
        		ui.fatal(e.message)
        		raise e
        	end
        	puts "Security Rule #{@secrule.name} created\n"
        end    	

        def validate_params!
          super
          errors = check_for_missing_config_values!(:name, :src_list, :dst_list, :application, :action, :oraclepaas_username, :oraclepaas_password, :oraclepaas_domain, :oraclepaas_compute_api)
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


