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
            {:label => 'IP', :key => 'ip_address'},
            {:label => 'Created By', :key=>'created_by'},
            {:label => 'Last modified', :key=>'last_modified_time'}
          ]
          super
        end

        def format_status_value(status)
          status = status.downcase
          status_color = case status
                         when 'running'
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
