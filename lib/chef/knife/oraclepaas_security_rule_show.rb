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
      class OraclepaasSecruleShow < Command
        include OraclepaasHelpers

        banner "knife oraclepaas secrule show NAME"

        def create_service_instance     
          ComputeService.new
        end

        def before_exec_command
          @columns_with_info = [
            {:label => 'Name', :key => 'name'},
            {:label => 'Source', :key => 'src_list'},
            {:label => 'Destination', :key => 'dst_list'},
            {:label => 'Action', :key => 'action'},
            {:label => 'Application', :key => 'application'},
            {:label => 'Disabled?',  :key =>'disabled' },
            {:label => 'URI', :key=>'uri'},
            {:label => 'Proxy URI', :key=>'proxyuri'}
          ]
          super
        end

        def execute_command
        	secrule = service.get_security_rule(locate_config_value(:security_rule_name))
          if secrule.nil?
            error_message = "Security Rule #{locate_config_value(:security_rule_name)} does not exist."
            ui.error(error_message)
            raise CloudExceptions::ServerShowError, error_message
          else
            service.server_summary(secrule, @columns_with_info)
          end
        end  

        def validate_params!
          super
          errors = check_for_missing_config_values!(:oraclepaas_username, :oraclepaas_password, :oraclepaas_domain, :oraclepaas_compute_api)
          config[:security_rule_name] = @name_args.first
          if locate_config_value(:security_rule_name).nil?
          	errors << 'Security Rule Name'
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
