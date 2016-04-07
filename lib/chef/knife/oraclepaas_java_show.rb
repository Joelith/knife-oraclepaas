#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/server/show_command'
require 'chef/knife/oraclepaas_helpers'
require 'chef/knife/cloud/server/show_options'
require 'chef/knife/cloud/oraclepaas_java_service'
require 'chef/knife/cloud/oraclepaas_service_options'
require 'chef/knife/cloud/exceptions'

class Chef
  class Knife
    class Cloud
      class OraclepaasJavaShow < ServerShowCommand
        include OraclepaasHelpers
        include OraclepaasServiceOptions
        include ServerShowOptions

        banner "knife oraclepaas java show (options)"

        def create_service_instance     
          JavaService.new
        end

        def before_exec_command
          @columns_with_info = [
            {:label => 'Description', :key => 'description'},
            {:label => 'Version', :key => 'version'},
            {:label => 'Status',  :key =>'status', :value_callback => method(:format_status_value) },
            {:label => 'Created By', :key=>'created_by'},
            {:label => 'Last modified', :key=>'last_modified_time'},
          ]
          @server_columns = [
            {:label => 'Name', :key => 'name'},
            {:label => 'IP Address', :key => 'ip_addr'},
            {:label => 'Shape', :key => 'shape'},
            {:label => 'Status',  :key =>'status', :value_callback => method(:format_status_value) }
          ]
          super
        end

        def execute_command
          instance = service.get_server(locate_config_value(:instance_id))
          if instance.nil?
            error_message = "Invalid #{locate_config_value(:instance_id)} instance name."
            ui.error(error_message)
            raise CloudExceptions::ServerShowError, error_message
          else
            service.server_summary(instance, @columns_with_info)
            puts "\n" + ui.color('Managed Servers', :bold)
            instance.servers.each_with_index do |server, index|
              puts ui.color("Server \##{index+1}", :bold)
              service.server_summary(server, @server_columns)
            end
          end
        end

        def format_status_value(status)
          status = status.downcase
          status_color = case status
                         when 'running', 'ready'
                           :green
                         when 'stopped'
                           :red
                         else
                           :yellow
                         end
          ui.color(status, status_color)
        end
      end
    end
  end
end
