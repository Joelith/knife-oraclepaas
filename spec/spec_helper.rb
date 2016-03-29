$:.unshift File.expand_path('../../lib', __FILE__)
require 'chef/knife/bootstrap'
require 'chef/knife/oraclepaas_helpers'
require 'fog'
require 'chef/knife/winrm_base'
require 'chef/knife/bootstrap_windows_winrm'
require 'chef/knife/oraclepaas_server_create'
require 'chef/knife/oraclepaas_server_delete'
require 'chef/knife/bootstrap_windows_ssh'
require "securerandom"
require 'knife-oraclepaas/version'
require 'test/knife-utils/test_bed'
require 'resource_spec_helper'

