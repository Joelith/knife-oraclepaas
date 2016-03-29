#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/server/list_command'
require 'chef/knife/oraclepaas_helpers'
require 'chef/knife/cloud/oraclepaas_database_service'
require 'chef/knife/cloud/oraclepaas_service_options'

class Chef
  class Knife
    class Cloud
      class OraclepaasDatabaseList < ResourceListCommand
        include OraclepaasHelpers
        include OraclepaasServiceOptions

        banner "knife oraclepaas database list (options)"

        def create_service_instance     
          DatabaseService.new
        end
        
        def before_exec_command
          @columns_with_info = [
            { label: 'Full Name',         key: 'service_name' },
            { label: 'Status',            key: 'status', value_callback: method(:format_status_value) },
            { label: 'Shape',             key: 'shape' },
            { label: 'Connection String', key: 'connect_descriptor' }            
          ]

          @sort_by_field = 'service_name'
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
