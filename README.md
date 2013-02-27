## VM Creator

### Description

This script can be used to bulk create and customize virtual machines in vSphere utilizing the [Fog](http://fog.io) and [RbVmomi](https://github.com/vmware/rbvmomi) libraries. The CSV format contains the following attributes

  * hostname
  * ipaddress
  * NIC tag (the network label, currently unused)
  * Memory (in GB)
  * vCPU count

### Memory configuration

This script converts the number in the CSV into MB by the forumla of ( 1024 * memory ) and reconfigures the VM post cloning with the value specified.

### vCPU configuration

There is no formula, this script takes the value and reconfigures the VM post cloning with the value specified.

### Network configuration

  * NIC Tag, Future will be to reconfigure the primary NIC to use a specific network label. Currently unused but is needed for CSV format.
  * IP Address, The format is x.x.x.x, so for example 192.168.1.12
  * Name server, The format follows the same format as IP Address.
  * Domain, The domain the VM will be configured, an example would be example.com
  * Gateway, The gateway is not configurable and is assumed based off the IP Address for the VM. So if the VM is 192.168.1.12 the script assumes the gateway is 192.168.1.1
  * Subnet mask, The subnet mask is not configurable and is assumed to be 255.255.255.0 

### Parameters

  * "--folder PATH", The folder path where the Virtual Machine clone will reside.
  * "--datastore DATASTORE", The datastore where the Virtual Machine clone will reside.
  * "--cluster CLUSTER", The compute cluster the Virtual Machine clone will utilize.
  * "--datacenter DATACENTER", The datacenter the virtual machine will be located.
  * "--resourcepool RESOURCEPOOL", The resource pool the virtual machine will be located.
  * "--nameserver IPADDRESS", The IP address of the nameserver the virtual machine clone will use.
  * "--domain DOMAIN", The DNS domain the virtual machine will use.
  * "--file FILENAME", The CSV file to load to create virtual machines.
  * "--template_path TEMPLATEPATH", The path to the template that will be used for virtual machine cloning.
  * "--template TEMPLATE", The virtual machine or template to use for the cloning.

### Example command execution

./vmcreator.rb --datacenter DATACENTER01 --folder "Web/Production" --datastore Production --cluster CLUSTER01 --resourcepool Webservers --filename servers.csv --nameserver 192.168.1.2 --domain example.com --template-path "VM Templates" --template "Webserver Template"

### Example CSV
    webserver01,192.168.1.10,Web,4,2
    webserver02,192.168.1.11,Web,4,2
    webserver03,192.168.1.12,Web,4,2
    appserver01,192.168.2.10,App,16,4
    appserver02,192.168.2.11,App,16,4
    appserver03,192.168.2.12,App,16,4
    appserver04,192.168.2.13,App,16,4
    appserver05,192.168.2.14,App,16,4
    appserver06,192.168.2.15,App,16,4

