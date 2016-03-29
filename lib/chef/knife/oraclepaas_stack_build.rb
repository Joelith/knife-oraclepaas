#
# Author::
# Copyright::
#

#require 'chef/knife/cloud/oraclepaas_stack_service'
require 'chef/knife/oraclepaas_helpers'

class Chef
  class Knife
    class Cloud
      class OraclepaasStackBuild < Knife
        include OraclepaasHelpers

        banner "knife oraclepaas stack build STACK_FILE (options)"
   
        option :show_stack_file,
               :long => "--show-stack-file",
               :description => "Outputs the parsed yaml of the stack file and exits."

        def run
          validate_params!
          
          stack_file = name_args.first
          if stack_file=~/^[-_+=.0-9a-zA-Z]+$/
            stack_file = Dir.getwd + '/' + stack_file + (stack_file.end_with?('.yml') ? '' : '.yml')
          end
          unless File.exist?(stack_file)
            puts "Stack file '#{stack_file}' does not exist."
            exit 1
          end

          stack = load_yaml(stack_file)
          if locate_config_value(:show_stack_file)
            puts("Stack file:\n#{stack.to_yaml}")
            exit 1
          end
          if stack.has_key?("instances") && stack["instances"].is_a?(Array)
            instances = stack["instances"]
          else
            raise ArgumentError, "YAML needs to have at least one instance defined."
          end
          instances.each do |n|
            print "Creating #{n["type"]} instance: #{n["service_name"]}\n"
            case n["type"]
              when "java" 
                knife_cmd = Chef::Knife::Cloud::OraclepaasJavaCreate.new
              when "database" 
                knife_cmd = Chef::Knife::Cloud::OraclepaasDatabaseCreate.new
              when "storage"
                knife_cmd = Chef::Knife::Cloud::OraclepaasStorageCreate.new
              else
                raise ArgumentError, "Invalid instance type: #{n["type"]}"
            end
            knife_cmd.config[:bootstrap_protocol] = 'ssh'
            n["config"].each do |key, value|
              knife_cmd.config[key.to_sym] = value
            end
            knife_cmd.run
          end
        end

        def validate_params!
          errors = check_for_missing_config_values!(:oraclepaas_vm_public_key)
          if errors.any?
            error_message = "The following required parameters are missing: #{errors.join(', ')}"
            ui.error(error_message)
            raise CloudExceptions::ValidationError, error_message
          end
        end

        def load_yaml(file, my = nil)
          yaml = YAML.load_file(file)
        end
        
      end
    end
  end
end
