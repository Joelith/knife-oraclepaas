#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/server/list_command'
require 'chef/knife/oraclepaas_helpers'
require 'chef/knife/cloud/oraclepaas_compute_service'
require 'chef/knife/cloud/oraclepaas_service_options'

class Chef
  class Knife
    class Cloud
      class OraclepaasComputeList < ResourceListCommand
        include OraclepaasHelpers
        include OraclepaasServiceOptions

        banner "knife oraclepaas compute list (options)"

        def create_service_instance     
          ComputeService.new
        end

        def before_exec_command
          @columns_with_info = [
            { label: 'Full Name',        key: 'service_name' },
          ]

          @sort_by_field = 'service_name'
        end

      end
    end
  end
end
