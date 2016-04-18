#
# Author::
# Copyright::
#

require 'chef/knife/cloud/server/create_command'
require 'chef/knife/oraclepaas_helpers'
require 'chef/knife/cloud/oraclepaas_server_create_options'
require 'chef/knife/cloud/oraclepaas_soa_service'
require 'chef/knife/cloud/oraclepaas_service_options'
require 'chef/knife/cloud/exceptions'

class Chef
  class Knife
    class Cloud
      class OraclepaasSoaCreate < ServerCreateCommand
        include OraclepaasHelpers
        include OraclepaasServerCreateOptions
        include OraclepaasServiceOptions


        banner "knife oraclepaas soa create (options)"

        option :service_name,
               long:        '--service_name SERVICE_NAME',
               description: 'Name of the instance to be created'
        option :description,
               long:        '--description DESCRIPTION',
               description: 'optional; Free-form text that provides additional information about the service instance'
        option :level,
               long:        '--level [PAAS]',
               description: 'optional; Service level' 
        option :provision_otd,
               long:        '--provision_otd',
               description: 'Flag that specifies whether to enable the load balancer'
        option :sample_app,
               long:        '--sample_app',
               description: 'Flag that specifies whether to automatically deploy and start the sample application'
        option :subscription_type,
               long:        '--subscription_type [HOURLY]',
               description: 'Billing unit'
        option :topology,
               long:        '--topology [osb|soa|soaosb|b2b|mft|apim]',
               description: 'Topology name'
        option :cloud_storage_container,
               long:        '--cloud_storage_container CONTAINER',
               description: 'Name of the Oracle Storage Cloud Service container used to provide storage for your service instance backups'
        option :weblogic_version,
               long:        '--weblogic_version [12.1.3.0.5|10.3.6.0.12]',
               description: 'Oracle WebLogic Server software version'
        option :weblogic_edition,
               long:        '--weblogic_edition [SE|EE|SUITE]',
               description: 'Software edition for WebLogic Server'
        option :server_count,
               long:        '--server_count [1|2|4|8]',
               description: 'Number of Managed Servers in the domain'
        option :shape,
               long:        '--shape [oc1m|oc2m|oc3m|oc4m]',
               description: 'Desired compute shape'
        option :domain_volume_size,
               long:        '--domain_volume_size SIZE',
               description: 'Size of the domain volume for the service'  
        option :backup_volume_size,
               long:        '--backup_volume_size SIZE',
               description: 'Size of the backup volume for the service'
        option :db_service_name,
               long:        '--db_service_name NAME',
               description: 'Name of the Oracle Database Cloud - Database as a Service instance'
        option :dba_name,
               long:        '--dba_name NAME',
               description: 'Username for the Oracle Database Cloud - Database as a Service instance administrator'
        option :dba_password,
               long:        '--dba_password PASSWORD',
               description: 'Password for the Oracle Database Cloud - Database as a Service instance administrator'

        def create_service_instance
          SoaService.new
        end

        def before_exec_command
          super
          identity_domain = Chef::Config[:knife][:oraclepaas_domain]
          server_def ={
            service_name: locate_config_value(:service_name),
            cloudStorageContainer: "Storage-#{identity_domain}/#{locate_config_value(:cloud_storage_container)}",
            cloudStorageUser: locate_config_value(:oraclepaas_username),
            cloudStoragePassword: locate_config_value(:oraclepaas_password),
            description: locate_config_value(:description),
            level: 'PAAS',
            subscriptionType: 'MONTHLY',
            topology: locate_config_value(:topology),
            provisionOTD: locate_config_value(:provision_otd) || false,
            parameters: []
          }
          if locate_config_value(:provision_otd)
            #TODO
          end
          # Add Weblogic parameters
          server_def[:parameters] << {
            type: 'weblogic',
            version: locate_config_value(:weblogic_version) || '12.1.3',
            managedServerCount: locate_config_value(:server_count) || '1',
            adminUserName: locate_config_value(:weblogic_admin_name) || 'weblogic',
            adminPassword: locate_config_value(:weblogic_admin_password) || 'welcome1',
            dbServiceName: locate_config_value(:db_service_name),
            dbaName: locate_config_value(:dba_name),
            dbaPassword: locate_config_value(:dba_password),
            shape: locate_config_value(:shape),
            VMsPublicKey: locate_config_value(:oraclepaas_vm_public_key)
          }
          
          @create_options = {
            server_create_timeout: 7200,
            server_def: server_def
          }                   
        end

        # Setup the floating ip after server creation.
        def after_exec_command
          # Any action you want to perform post VM creation in your cloud.
          # Example say assigning floating IP to the newly created VM.
          # Make calls to "service" object if you need any information for cloud, example service.connection.addresses
          # Make call to "server" object if you want set properties on newly created VM, example server.associate_address(floating_address)

          super
        end

        def before_bootstrap
          super
          bootstrap_ip_address = server.ip_address
          Chef::Log.debug("Bootstrap IP Address: #{bootstrap_ip_address}")
          if bootstrap_ip_address.nil?
            error_message = "No IP address available for bootstrapping."
            ui.error(error_message)
            raise CloudExceptions::BootstrapError, error_message
          end
          config[:bootstrap_ip_address] = bootstrap_ip_address
        end

        def validate_params!
          super
          errors = check_for_missing_config_values!(:service_name, :cloud_storage_container, :oraclepaas_username, :oraclepaas_password, :oraclepaas_vm_public_key, :shape, :db_service_name, :dba_name, :dba_password, :topology)
          if errors.any?
            error_message = "The following required parameters are missing: #{errors.join(', ')}"
            ui.error(error_message)
            raise CloudExceptions::ValidationError, error_message
          end
        end

        def post_connection_validations
          errors = []

          # TODO - Add validations that need to be done after connection to the cloud provider
          # Eg -
          # errors << "You have not provided a valid image ID. " if !is_image_valid?
          error_message = ""
          raise CloudExceptions::ValidationError, error_message if errors.each{|e| ui.error(e); error_message = "#{error_message} #{e}."}.any?
        end

      end
    end
  end
end
