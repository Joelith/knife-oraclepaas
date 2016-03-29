#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/server/show_command'
require 'chef/knife/oraclepaas_helpers'
require 'chef/knife/cloud/server/show_options'
require 'chef/knife/cloud/oraclepaas_soa_service'
require 'chef/knife/cloud/oraclepaas_service_options'
require 'chef/knife/cloud/exceptions'

class Chef
  class Knife
    class Cloud
      class OraclepaasSoaShow < ServerShowCommand
        include OraclepaasHelpers
        include OraclepaasServiceOptions
        include ServerShowOptions

        banner "knife oraclepaas database show (options)"

        def create_service_instance     
          SoaService.new
        end
        
        def before_exec_command
          @columns_with_info = [
            {:label => 'Name', :key => 'service_name'},
            {:label => 'Description', :key => 'description'},
            {:label => 'Type', :key => 'service_type'},
            {:label => 'Status',  :key =>'status', :value_callback => method(:format_status_value) }
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
