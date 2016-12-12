#
# Author::
# Copyright::
#

require 'chef/knife/cloud/server/create_command'
require 'chef/knife/oraclepaas_helpers'
require 'chef/knife/cloud/oraclepaas_server_create_options'
require 'chef/knife/cloud/oraclepaas_java_service'
require 'chef/knife/cloud/oraclepaas_service_options'
require 'chef/knife/cloud/exceptions'
require 'resolv'

class Chef
  class Knife
    class Cloud
      class OraclepaasJavaCreate < ServerCreateCommand
        include OraclepaasHelpers
        include OraclepaasServerCreateOptions
        include OraclepaasServiceOptions


        banner "knife oraclepaas java create (options)"

        option :service_name,
               long:        '--service_name SERVICE_NAME',
               description: 'Name of the instance to be created'
        option :description,
               long:        '--description DESCRIPTION',
               description: 'optional; Free-form text that provides additional information about the service instance'
        option :level,
               long:        '--level [PAAS|BASIC]',
               description: 'optional; Service level' 
        option :provision_otd,
               long:        '--provision_otd',
               description: 'Flag that specifies whether to enable the load balancer'
        option :sample_app,
               long:        '--sample_app',
               description: 'Flag that specifies whether to automatically deploy and start the sample application'
        option :subscription_type,
               long:        '--subscription_type [HOURLY|MONTHLY]',
               description: 'Billing unit'
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
        option :domain_name,
               long:        '--domain_name DOMAIN',
               description: 'Name of the WebLogic domain'
        option :shape,
               long:        '--shape [oc3|oc4|oc5|oc6|oc1m|oc2m|oc3m|oc4m]',
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
          JavaService.new
        end

        def before_exec_command
          super
          identity_domain = Chef::Config[:knife][:oraclepaas_domain]
          server_def = { 
            service_name: locate_config_value(:service_name),
            cloudStorageContainer: "Storage-#{identity_domain}/#{locate_config_value(:cloud_storage_container)}",
            cloudStorageUser: locate_config_value(:oraclepaas_username),
            cloudStoragePassword: locate_config_value(:oraclepaas_password),
            description: locate_config_value(:description),
            level: locate_config_value(:level) || 'PAAS',
            subscriptionType: locate_config_value(:subscription_type) || 'HOURLY',
            provisionOTD: locate_config_value(:provision_otd) || false,
            version: locate_config_value(:weblogic_version),
            edition: locate_config_value(:weblogic_edition),
            managedServerCount: locate_config_value(:server_count) || '1',
            domainName: locate_config_value(:domain_name),
            admin_username: locate_config_value(:weblogic_admin_name) || 'weblogic',
            admin_password: locate_config_value(:weblogic_admin_password) || "#{locate_config_value(:service_name)[0,8]}\#1",
            shape: locate_config_value(:shape),
            domainVolumeSize: locate_config_value(:domain_volume_size),
            backupVolumeSize: locate_config_value(:backup_volume_size),
            ssh_key: locate_config_value(:oraclepaas_vm_public_key),
            db_service_name: locate_config_value(:db_service_name),
            dba_name: locate_config_value(:dba_name),
            dba_password: locate_config_value(:dba_password)
          }
          server_def.delete_if { |k, v| v.nil? }
          @create_options = {
            server_create_timeout: 7200,
            server_def: server_def
          } 
        end

        # Setup the floating ip after server creation.
        def after_exec_command
          # Open default networking ports
          compute_service = ComputeService.new
          container = "/Compute-#{locate_config_value(:oraclepaas_domain)}/#{locate_config_value(:oraclepaas_username)}"
          service_name = locate_config_value(:service_name)
          # First create a security application for the managed ports
          secapps = [{"port" => 8001, "name" => "HTTP"},{"port" => 8002,"name" => "HTTPS"}]
          secapps.each do |app|
            begin
              compute_service.create_security_application({
                name: "#{container}/#{service_name}-MS-#{app['name']}",
                protocol: 'tcp',
                dport: app['port'],
                description: "#{app['name']} port for managed servers"
              })
            rescue CloudExceptions::ServerCreateError => e
              # Most likely the secapp already exists. Warn and move on
              puts "#{e}\n"
            end
          end
          # Then create a security rule with this security application for the managed servers
          secrules = ["HTTP","HTTPS"]
          secrules.each do |name|
            begin
              compute_service.create_security_rule({
                name: "#{container}/#{service_name}-Public-MS-#{name}",
                src_list: 'seciplist:/oracle/public/public-internet',
                dst_list: "seclist:#{container}/jaas/#{locate_config_value(:service_name)}/wls/ora_ms",
                application: "#{container}/#{service_name}-MS-#{name}",
                action: 'PERMIT',
                description: "Enable access to #{name}"
              })
             rescue CloudExceptions::ServerCreateError => e
              # Most likely the secrule already exists. Warn and move on
              puts "#{e}\n"
            end
          end 

          # Bootstrap each of the managed servers in this instance
          server.servers.each do |server|
            Chef::Log.info("Bootstrapping Managed Server #{server.name} (#{server.ip_addr})")
            if server.ip_addr.blank?
              error_message = "No IP address for #{server.name}"
              ui.error(error_message)
              next
            end
            if server.ip_addr !~ Resolv::IPv4::Regex
              error_message = "Invalid IP address returned for #{server.name}. This is probably due to non-admin servers in the Java Cloud Service not getting public ips. Until this script can get a valid IP address and configure the network you will not be able to bootstrap this machine."
              ui.error(error_message)
              next
            end
            config[:bootstrap_ip_address] = server.ip_addr
            config[:chef_node_name] = 'JCS_' + locate_config_value(:service_name) + '_' + server.name
            config[:first_boot_attributes] = {
              "oracle" => {
                service_name: locate_config_value(:service_name),
                db_service_name: locate_config_value(:db_service_name),
                dba_name: locate_config_value(:dba_name),
                dba_password: locate_config_value(:dba_password),
                identity_domain: locate_config_value(:oraclepaas_domain),
                weblogic_password: locate_config_value(:weblogic_admin_password) || "#{locate_config_value(:service_name)}\#1"
              }
            }
            begin
              # bootstrap the server
              bootstrap
            rescue CloudExceptions::BootstrapError => e
              ui.fatal(e.message)
              cleanup_on_failure
              raise e
            rescue => e
              error_message = "Check if --bootstrap-protocol and --image-os-type is correct. #{e.message}"
              ui.fatal(error_message)
              cleanup_on_failure
              raise e, error_message
            end
          end
        end

        def validate_params!
          super
          errors = check_for_missing_config_values!(:service_name, :cloud_storage_container, :oraclepaas_username, :oraclepaas_password, :oraclepaas_vm_public_key, :weblogic_edition, :weblogic_version, :shape, :db_service_name, :dba_name, :dba_password)
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
