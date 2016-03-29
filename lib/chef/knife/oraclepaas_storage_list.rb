#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/server/list_command'
require 'chef/knife/oraclepaas_helpers'
require 'chef/knife/cloud/oraclepaas_storage_service'
require 'chef/knife/cloud/oraclepaas_service_options'

class Chef
  class Knife
    class Cloud
      class OraclepaasStorageList < ResourceListCommand
        include OraclepaasHelpers
        include OraclepaasServiceOptions

        banner "knife oraclepaas storage list (options)"

        def create_service_instance     
          StorageService.new
        end

        def before_exec_command
          @columns_with_info = [
            { label: 'Name',        key: 'name' },
            { label: 'Size',        key: 'bytes', value_callback: method(:format_bytes) }
          ]

          @sort_by_field = 'name'
        end

        def format_bytes(bytes)
          giga = bytes / 1024 / 1024 / 1024
          "#{giga} Gb"
        end

      end
    end
  end
end
