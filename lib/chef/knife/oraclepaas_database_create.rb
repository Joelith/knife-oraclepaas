#
# Author::
# Copyright::
#

require 'chef/knife/cloud/server/create_command'
require 'chef/knife/oraclepaas_helpers'
require 'chef/knife/cloud/oraclepaas_server_create_options'
require 'chef/knife/cloud/oraclepaas_database_service'
require 'chef/knife/cloud/oraclepaas_service_options'
require 'chef/knife/cloud/exceptions'

class Chef
  class Knife
    class Cloud
      class OraclepaasDatabaseCreate < ServerCreateCommand
        include OraclepaasHelpers
        include OraclepaasServerCreateOptions
        include OraclepaasServiceOptions


        banner "knife oraclepaas database create (options)"

        option :service_name,
               long:        '--service_name SERVICE_NAME',
               description: 'Name of the instance to be created'
        option :description,
               long:        '--description DESCRIPTION',
               description: 'optional; Free-form text that provides additional information about the service instance'
        option :level,
               long:        '--level [PAAS|BASIC]',
               description: 'optional; Service level' 
        option :shape,
               long:        '--shape [oc3|oc4|oc5|oc6|oc7|oc1m|oc2m|oc3m|oc4m|oc5m]',
               description: 'Desired compute shape'       
        option :version,
               long:        '--version [12.1.0.2|11.2.0.4]',
               description: 'A string containing the Oracle Database version for the service instance'
        option :edition,
               long:        '--edition [SE|EE|EE_HP|EE_EP]',
               description: 'A string containing the database edition for the service instance:'
        option :subscription_type,
               long:        '--subscription_type [HOURLY|MONTHLY]',
               description: 'Billing unit'
        option :usable_storage,
               long:        '--usable_storage SIZE',
               description: 'A string containing the number of GB of usable data storage for the Oracle Database server .'
        option :admin_password,
               long:        '--admin_password PASSWORD',
               description: 'A string containing the administrator password for the service instance.'
        option :sid,
               long:        '--sid SID',
               description: 'The SID for the service instance'
        option :pdb,
               long:        '--pdb PDB',
               description: 'The PDB for the service instance'
        option :backup_destination,
               long:        '--backup_destination [BOTH|DISK|NONE]',
               description: 'Backup configuration'
        option :failover_database,
               long:        '--failover_database [yes|no]',
               description: 'Undocumented in API'
        option :cloud_storage_container,
               long:        '--cloud_storage_container CONTAINER',
               description: 'Name of the Oracle Storage Cloud Service container used to provide storage for your service instance backups'
        

        def create_service_instance
          DatabaseService.new
        end

        def before_exec_command
          super
          identity_domain = Chef::Config[:knife][:oraclepaas_domain]
          server_def = {
            service_name: locate_config_value(:service_name),
            description: locate_config_value(:description),
            level: locate_config_value(:level) || 'PAAS',
            subscriptionType: locate_config_value(:subscription_type) || 'HOURLY',
            edition: locate_config_value(:edition),
            version: locate_config_value(:version) || '12.1.0.2',
            shape: locate_config_value(:shape),
            vmPublicKey: locate_config_value(:oraclepaas_vm_public_key),
            parameters: [{
              cloudStorageContainer: "Storage-#{identity_domain}/#{locate_config_value(:cloud_storage_container)}",
              cloudStorageUser: locate_config_value(:oraclepaas_username),
              cloudStoragePassword: locate_config_value(:oraclepaas_password),
              type: 'db',
              usableStorage: locate_config_value(:usable_storage) || 15,
              adminPassword: locate_config_value(:admin_password),
              sid: locate_config_value(:sid),
              pdb: locate_config_value(:pdb),
              backupDestination: locate_config_value(:backup_destination) || 'NONE',
              failoverDatabase: locate_config_value(:failover_database) || 'no'
            }]
          }

          @create_options = {
            server_create_timeout: 7200,
            server_def: server_def
          }
        end

        def get_id(value)
          value['id']
        end

        # Setup the floating ip after server creation.
        def after_exec_command
         # At this moment, don't bootstrap database instances. 
        end

        def validate_params!
          super
          errors = check_for_missing_config_values!(:service_name, :cloud_storage_container, :oraclepaas_username, :oraclepaas_password, :oraclepaas_vm_public_key, :edition, :shape, :admin_password, :sid, :pdb)
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
