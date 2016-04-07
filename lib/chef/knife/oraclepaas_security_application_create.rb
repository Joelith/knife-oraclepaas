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
      class OraclepaasSecappCreate < Command
        include OraclepaasHelpers
        include OraclepaasServiceOptions

        banner "knife oraclepaas secapp create (options)"

        option :name,
               long:        '--name NAME',
               description: 'Name of the security application. Can only contain alphanumeric characters, hyphens, underscores and periods. Your identity domain and username will be prepended automatically.'
        option :protocol,
               long:        '--protocol PROTOCOL',
               description: 'Name of the protocol to use'
        option :dport,
               long:        '--dport PORT',
               description: 'The TCP or UDP destination port number'
        option :icmptype,
               long:        '--icmptype TYPE',
               description: 'The ICMP type'
        option :icmpcode,
               long:        '--icmpcode CODE',
               description: 'The ICMP code'
        option :description,
               long:        '--description DESCRIPTION',
               description: 'A description of the security application'

				 def create_service_instance     
          ComputeService.new
        end    

  			def before_exec_command
          super
         	@create_options = {
         		name: "/Compute-#{locate_config_value(:oraclepaas_domain)}/#{locate_config_value(:oraclepaas_username)}/#{locate_config_value(:name)}",
         		protocol: locate_config_value(:protocol),
         		dport: locate_config_value(:dport),
         		icmptype: locate_config_value(:icmptype),
         		icmpcode: locate_config_value(:icmpcode),
         		description: locate_config_value(:description)
         	}
          @create_options.delete_if { |k, v| v.nil? }                
        end

        def execute_command
        	begin
        		@secapp = service.create_security_application(@create_options)
        	rescue CloudExceptions::ServerCreateError => e
        		ui.fatal(e.message)
        		raise e
        	end
        	puts "Security application #{@secapp.name} created\n"
        end    	

        def validate_params!
          super
          errors = check_for_missing_config_values!(:name, :protocol, :oraclepaas_username, :oraclepaas_password, :oraclepaas_domain, :oraclepaas_compute_api)
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


