class Chef
  class Knife
		module OracleBuilderBase
      def self.included(includer)
				includer.class_eval do

					deps do
						require 'oraclebuilder'
					end
				end
 				def getConfig(key)
					key = key.to_sym
					config[key] || Chef::Config[:knife][key]
				end

				def check_for_missing_config_values!(*keys)
          missing = keys.select { |x| getConfig(x).nil? }
          missing
        end
      end
		end
	end
end
