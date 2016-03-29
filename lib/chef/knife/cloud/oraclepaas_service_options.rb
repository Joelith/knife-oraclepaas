#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/fog/options'
class Chef
  class Knife
    class Cloud
      module OraclepaasServiceOptions

       def self.included(includer)
          includer.class_eval do
            include FogOptions

            # TODO - define your cloud specific auth options.
            # Example:
            # Oraclepaas Connection params.
            #option :oraclepaas_username,
            #  :short => "-A USERNAME",
            #  :long => "--oraclepaas-username KEY",
            #  :description => "Your Oraclepaas Username",
            #  :proc => Proc.new { |key| Chef::Config[:knife][:oraclepaas_username] = key }
          end
        end
      end
    end
  end
end
