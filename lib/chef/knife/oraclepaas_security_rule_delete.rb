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
      class OraclepaasSecruleDelete < Command
        include OraclepaasHelpers

        banner "knife oraclepaas secrule delete NAME"

        def create_service_instance     
          ComputeService.new
        end

        def execute_command
        	begin
        		@secapp = service.delete_security_rule(locate_config_value(:security_rule_name))
        	rescue CloudExceptions::ServerCreateError => e
        		ui.fatal(e.message)
        		raise e
        	end
        	puts "Security rule #{locate_config_value(:security_rule_name)} deleted\n"
        end  

        def validate_params!
          super
          errors = check_for_missing_config_values!(:oraclepaas_username, :oraclepaas_password, :oraclepaas_domain, :oraclepaas_compute_api)
          config[:security_rule_name] = @name_args.first
          if locate_config_value(:security_rule_name).nil?
          	errors << 'Security Rules Name'
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
