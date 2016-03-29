#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/oraclepaas_service_options'

class Chef
  class Knife
    class Cloud
      module OraclepaasHelpers

        # TODO - Define helper methods used across your commands 

        def query_resource
          @service.list_instances
        end

        def check_for_missing_config_values!(*keys)
          missing = keys.select { |x| locate_config_value(x).nil? }
          missing
        end
        
        def locate_config_value(key)
          key = key.to_sym
          Chef::Config[:knife][key] || config[key]
        end
        
        def validate!
          # TODO - update these as per your cloud. Validating auth params defined in service options
          super(:oraclepaas_username, :oraclepaas_password, :oraclepaas_domain)
        end

      end
    end
  end
end
