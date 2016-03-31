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

In order to communicate with the Oracle Cloud Platform you will need to pass Knife your username, password and identity domain. This can be done in several ways:

The easiest way to configure your credentials for knife-oraclepaas is to specify them in your your `knife.rb` file:

```ruby
knife[:oraclepaas_username] = "Your Oracle Cloud username"
knife[:oraclepaas_password] = "Your Oracle Cloud password"
knife[:oraclepaas_domain] = "Your Oracle Cloud identity domain"
knife[:oraclepaas_vm_public_key] = "The public key that you use for your VMs (as text, eg: ssh-rsa <long string>)"
```


# Services #
## List
`knife oraclepaas [java|database|soa|storage] list`
Returns a list of all instances in that cloud service. There are no options to this command.

## Show
`knife oraclepaas [java|database|soa|storage] show`
Returns the details for an instance. There are no options to this command.

## Create
`knife oraclepaas [java|database|soa|storage] create (options)`
Create a new instance. There are various options depending on the service you call. This command will wait until the instance is actually provisioned (or timeout after 2 hours). Pass a 'run_list' if you want this plugin to bootstrap the server, register with your chef server and run your recipes.

Example:
```bash
knife oraclepaas java create --service_name MyJavaInstance --cloud_storage_container WeblogicBackup --shape oc3 --weblogic_edition SE --db_service_name MyDatabaseInstance --dba_name SYS --dba_password MyDB#1
```

## Stack
`knife oraclepaas [java|database|soa|storage] stack build stack.yaml (options)
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

- Deleting an instance is not currently supported
- This does not support the emea cloud service (which has a different cloud prefix)

# License #

Author: Joel Nation
Copyright: Copyright (c) 2016 Oracle Corporation
