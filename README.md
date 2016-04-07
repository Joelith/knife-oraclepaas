Knife Plugin for the Oracle Cloud Platform
===============

This plugin allows you to interact with the Oracle Cloud Platform from knife.


# Installation #

First, you'll need to install my forked version of [fog](https://github.com/Joelith/fog) until the Oracle extensions are added to the main repository. To do so:

1. Dowload the oracle modified version of [fog](https://github.com/Joelith/fog) to some directory
2. Navigate to that directory and run `chef gem build fog.gemspec`
3. Then run `chef gem install fog` to install into your chefdk library

Then you will need to install this plugin

1. Download the repository and navigate to it
2. Run `chef gem build knife-oraclepaas.gemspec`
3. Run `chef gem install knife-oraclepaas` to install into your chefdk library

# Configuration #

In order to communicate with the Oracle Cloud Platform you will need to pass Knife your username, password and identity domain. You will also need to provide the vm_public_key so that bootstrap mechanism can ssh into the box and the compute_api endpoint so that the script can interact with the compute cloud service.The easiest way to configure your credentials for knife-oraclepaas is to specify them in your your `knife.rb` file:

```ruby
knife[:oraclepaas_username] = 'Your Oracle Cloud username'
knife[:oraclepaas_password] = 'Your Oracle Cloud password'
knife[:oraclepaas_domain] = 'Your Oracle Cloud identity domain'
knife[:oraclepaas_vm_public_key] = 'The public key that you use for your VMs (as text, eg: ssh-rsa <long string>)'
knife[:oraclepaas_compute_api] = 'Something like http://api-z17.compute.us6.oraclecloud.com'
```

For bootstrapping to work you will also need to provide the identity_file and ssh_user details:

```ruby
knife[:identity_file] = 'Path to your identity file'
knife[:ssh_user] = 'opc' # The ssh user for the cloud is always opc

```

# Services #
## List
`knife oraclepaas [java|database|soa|storage|secapp|secrule|seclist] list`

Returns a list of all instances in that cloud service. There are no options to this command.

## Show
`knife oraclepaas [java|database|soa|storage|secrule] show`

Returns the details for an instance. There are no options to this command.

## Create
`knife oraclepaas [java|database|soa|storage|secapp|secrule] create (options)`

Create a new instance. There are various options depending on the service you call. This command will wait until the instance is actually provisioned (or timeout after 2 hours). Pass a 'run-list' if you want this plugin to bootstrap the server, register with your chef server and run your recipes.

Example:
```bash
knife oraclepaas java create --service_name MyJavaInstance --cloud_storage_container WeblogicBackup --shape oc3 --weblogic_edition SE --db_service_name MyDatabaseInstance --dba_name SYS --dba_password MyDB#1 --run-list ofmcanberra_example
```
*Unless otherwise documented the defaults for the below options will be what ever is the default in the respective cloud API*

### Create Java options
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>service_name</tt></td>
    <td>String</td>
    <td>Name of the instance to be created</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>description</tt></td>
    <td>String</td>
    <td>Free-form text that provides additional information about the service instance</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>level</tt></td>
    <td>PAAS|BASIC</td>
    <td>The service level. BASIC will provision virtual images with no cloud tooling</td>
    <td>PAAS</td>
  </tr>
  <tr>
    <td><tt>provision_otd</tt></td>
    <td>Boolean</td>
    <td>Flag that specifies whether to enable the load balancer. Currently not supported</td>
    <td>false</td>
  </tr>
  <tr>
    <td><tt>sample_app</tt></td>
    <td>String</td>
    <td>Flag that specifies whether to automatically deploy and start the sample application. Currently not supported</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>subscription_type</tt></td>
    <td>HOURLY|MONTHLY</td>
    <td>Billing unit</td>
    <td>HOURLY</td>
  </tr>
  <tr>
    <td><tt>cloud_storage_container</tt></td>
    <td>String</td>
    <td>Name of the Oracle Storage Cloud Service container used to provide storage for your service instance backups</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>weblogic_version</tt></td>
    <td>String</td>
    <td>The Oracle WebLogic Server software version. Currently supports 10.3.6.0.12, 12.1.3.0.5, 12.2.1</td>
    <td>12.1.3.0.5</td>
  </tr>
  <tr>
    <td><tt>weblogic_edition</tt></td>
    <td>SE|EE|SUITE</td>
    <td>Software edition for WebLogic Server</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>server_count</tt></td>
    <td>1|2|4|8</td>
    <td>Number of Managed Servers in the domain</td>
    <td>1</td>
  </tr>
  <tr>
    <td><tt>domain_name</tt></td>
    <td>String</td>
    <td>Name of the Weblogic domain</td>
    <td>First 6 characters of Service name + '_domain'</td>
  </tr>
  <tr>
    <td><tt>shape</tt></td>
    <td>oc3|oc4|oc5|oc6| oc1m|oc2m|oc3m|oc4m</td>
    <td>Desired compute shape</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>domain_volume_size</tt></td>
    <td>Integer</td>
    <td>Size of the domain volume for the service</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>backup_volume_size</tt></td>
    <td>Integer</td>
    <td>Size of the backup volume for the service</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>db_service_name</tt></td>
    <td>String</td>
    <td>Name of the Oracle Database Cloud - Database as a Service instance</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>dba_name</tt></td>
    <td>String</td>
    <td>Username for the Oracle Database Cloud - Database as a Service instance administrator</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>dba_password</tt></td>
    <td>String</td>
    <td>Password for the Oracle Database Cloud - Database as a Service instance administrator</td>
    <td></td>
  </tr>
</table>

### Create Database options
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>service_name</tt></td>
    <td>String</td>
    <td>Name of the instance to be created</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>description</tt></td>
    <td>String</td>
    <td>Free-form text that provides additional information about the service instance</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>level</tt></td>
    <td>PAAS|BASIC</td>
    <td>The service level. BASIC will provision virtual images with no cloud tooling</td>
    <td>PAAS</td>
  </tr>
  <tr>
    <td><tt>subscription_type</tt></td>
    <td>HOURLY|MONTHLY</td>
    <td>Billing unit</td>
    <td>HOURLY</td>
  </tr>
  <tr>
    <td><tt>cloud_storage_container</tt></td>
    <td>String</td>
    <td>Name of the Oracle Storage Cloud Service container used to provide storage for your service instance backups</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>version</tt></td>
    <td>String</td>
    <td>A string containing the Oracle Database version for the service instance. Currently supports 11.2.04 or 12.1.0.2</td>
    <td>12.1.0.2</td>
  </tr>
  <tr>
    <td><tt>edition</tt></td>
    <td>SE|EE|EE_HP|EE_EP</td>
    <td>Software edition for the database</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>usable_storage</tt></td>
    <td>Integer</td>
    <td>A string containing the number of GB of usable data storage for the Oracle Database server</td>
    <td>1</td>
  </tr>
  <tr>
    <td><tt>admin_password</tt></td>
    <td>String</td>
    <td>A string containing the administrator password for the service instance.</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>shape</tt></td>
    <td>oc3|oc4|oc5|oc6|oc7| oc1m|oc2m|oc3m|oc4m|oc5m</td>
    <td>Desired compute shape</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>sid</tt></td>
    <td>String</td>
    <td>The SID for the service instance</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>pdb</tt></td>
    <td>String</td>
    <td>The PDB for the service instance</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>backup_destination</tt></td>
    <td>BOTH|DISK|NONE</td>
    <td>Backup configuration</td>
    <td>NONE</td>
  </tr>
  <tr>
    <td><tt>failover_database</tt></td>
    <td>yes|no</td>
    <td>Undocumented in API</td>
    <td>no</td>
  </tr>
</table>

### Create SOA options
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>service_name</tt></td>
    <td>String</td>
    <td>Name of the instance to be created</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>description</tt></td>
    <td>String</td>
    <td>Free-form text that provides additional information about the service instance</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>level</tt></td>
    <td>PAAS</td>
    <td>The service level</td>
    <td>PAAS</td>
  </tr>
  <tr>
    <td><tt>provision_otd</tt></td>
    <td>Boolean</td>
    <td>Flag that specifies whether to enable the load balancer. Currently not supported</td>
    <td>false</td>
  </tr>
  <tr>
    <td><tt>sample_app</tt></td>
    <td>String</td>
    <td>Flag that specifies whether to automatically deploy and start the sample application. Currently not supported</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>subscription_type</tt></td>
    <td>HOURLY</td>
    <td>Billing unit</td>
    <td>HOURLY</td>
  </tr>
  <tr>
    <td><tt>cloud_storage_container</tt></td>
    <td>String</td>
    <td>Name of the Oracle Storage Cloud Service container used to provide storage for your service instance backups</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>weblogic_version</tt></td>
    <td>String</td>
    <td>The Oracle WebLogic Server software version. Currently supports 10.3.6.0.12 or 12.1.3.0.5</td>
    <td>12.1.3.0.5</td>
  </tr>
  <tr>
    <td><tt>weblogic_edition</tt></td>
    <td>SE|EE|SUITE</td>
    <td>Software edition for WebLogic Server</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>server_count</tt></td>
    <td>1|2|4|8</td>
    <td>Number of Managed Servers in the domain</td>
    <td>1</td>
  </tr>
  <tr>
    <td><tt>topology</tt></td>
    <td>osb|soa|soaosb|b2b|mft|apim</td>
    <td>What SOA software you want configured</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>shape</tt></td>
    <td>oc1m|oc2m|oc3m|oc4m</td>
    <td>Desired compute shape</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>domain_volume_size</tt></td>
    <td>Integer</td>
    <td>Size of the domain volume for the service</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>backup_volume_size</tt></td>
    <td>Integer</td>
    <td>Size of the backup volume for the service</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>db_service_name</tt></td>
    <td>String</td>
    <td>Name of the Oracle Database Cloud - Database as a Service instance</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>dba_name</tt></td>
    <td>String</td>
    <td>Username for the Oracle Database Cloud - Database as a Service instance administrator</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>dba_password</tt></td>
    <td>String</td>
    <td>Password for the Oracle Database Cloud - Database as a Service instance administrator</td>
    <td></td>
  </tr>
</table>
 
## Stack
`knife oraclepaas stack build stack.yaml (options)`

Provide a *yaml* file that details a number of java, database, soa and storage instances that you want created. This will create those instances in order, with pauses whilst each instance is provisioned. This will take some time!

Eg: this yaml file will create a storage, database and java instance. The parameters in the config align with the parameters for the equivalent *create* command:
```
---
instances:
  - type: storage
    config:
      name: KnifeBackup2
  - type: database
    config: 
      description: "Test for Knife. Ignore"
      service_name: KnifeTestDB4
      edition: SE
      shape: oc3
      cloud_storage_container: DatabaseBackup
      admin_password: "KnifeTest#1"
      sid: ORCL
      pdb: PDB1
  - type: java
    config:
      description: "Test for Knife. Ignore"
      service_name: KnifeTestWL4
      weblogic_edition: SE
      shape: oc3
      db_service_name: KnifeTestDB4
      dba_name: SYS
      dba_password: "KnifeTest#1"
      cloud_storage_container: DatabaseBackup
...
```

# Limitations

- This is provided as is and still needs some work to be fully productionised. 
- Deleting an instance is only supported for Java instances
- This does not support the emea cloud service (which has a different cloud prefix)

# License #

Author: Joel Nation
Copyright: Copyright (c) 2016 Oracle Corporation
