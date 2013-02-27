#!/usr/bin/env ruby
require 'fog'
require 'trollop'


opts = Trollop::options do
  banner <<-EOT
Creates VMs in vCenter following the following format of the file
hostname,ipaddress,nic network,memory,cpu

Usage:
   vmcreator.rb [options]
options are:
  EOT
  opt :folder, "--folder PATH", :type => :string
  opt :datastore, "--datastore DATASTORE", :type => :string
  opt :cluster, "--cluster CLUSTER", :type => :string
  opt :datacenter, "--datacenter DATACENTER", :type => :string
  opt :resourcepool, "--resourcepool RESOURCEPOOL", :type => :string
  opt :nameserver, "--nameserver IPADDRESS", :type => :string
  opt :domain, "--domain DOMAIN", :type => :string
  opt :filename, "--file FILENAME", :type => :string
  opt :template_path, "--template_path TEMPLATEPATH", :type => :string
  opt :template, "--template TEMPLATE", :type => :string
end
begin
  compute = Fog::Compute::Vsphere.new
rescue
  puts "Unable to connect to vCenter specified in ~/.fog"
  exit 1
end
Trollop::die :folder, "must be a real folder" if opts[:folder].nil?
Trollop::die :datastore, "must be a real datastore" if opts[:datastore].nil?
Trollop::die :cluster, "must be a real cluster" if opts[:cluster].nil?
Trollop::die :datacenter, "must be a real datacenter" if opts[:datacenter].nil?
Trollop::die :resourcepool, "must be a real resource pool" if opts[:resourcepool].nil?
Trollop::die :filename, "must be a real filename" if opts[:filename].nil?
Trollop::die :nameserver, "is required" if opts[:nameserver].nil?
Trollop::die :domain, "is required" if opts[:domain].nil?
begin
  compute.get_datacenter opts[:datacenter]
rescue
  Trollop::die :datacenter, "must be a real datacenter"
end

begin
  compute.get_datastore opts[:datastore], opts[:datacenter]
rescue
  Trollop::die :datastore, "must be a real datastore"
end

begin
  compute.get_cluster opts[:cluster], opts[:datacenter]
rescue
  Trollop::die :cluster, "must be a real cluster"
end

begin
  compute.get_resource_pool opts[:resourcepool],opts[:cluster], opts[:datacenter]
rescue
  Trollop::die :resourcepool, "must be a real resource pool"
end

begin
  compute.get_folder opts[:template_path], opts[:datacenter]
rescue
  Trollop::die :template_path, "must be a real path to template"
end

File.open(opts[:filename], "r") do |file|
  while(line = file.gets)
    hostname, ipaddress, nictag, memory, cpu = line.split(",")
    gateway = ipaddress.split(".")
    gateway[3] = "1"
    gateway = gateway.join(".")
    nictag.strip!
    memory = memory.to_i
    memory_in_mb = 1024 * memory
    options = {
      'datacenter' => opts[:datacenter],
      'template_path' => "#{opts[:template_path]}/#{opts[:template]}",
      'name' => hostname,
      'dest_folder' => compute.get_folder(opts[:folder], opts[:datacenter])[:path],
      'power_on' => false,
      'resource_pool' => [opts[:resourcepool]],
      'datastore' => opts[:datastore],
      'customization_spec' => {
         'domain' => opts[:domain],
	 'hostname' => hostname,
         'ipsettings' => {
            'ip' => ipaddress,
            'dnsServerList' => [opts[:nameserver]],
            'gateway' => [gateway],
            'subnetMask' => opts[:subnetmask] ||= "255.255.255.0"
         },
         'hostname' => hostname,
         'time_zone' => opts[:timezone] ||= "America/New_York"
      }
    }
    begin
      compute.vm_clone(options)
    rescue
    end
    vms = compute.list_virtual_machines({:folder => opts[:folder], :datacenter => opts[:datacenter]})
    vm = nil
    vms.each do |v|
      if v["name"] == hostname
	vm = v
      end
    end 
    puts "VM not found!" if vm.nil?
    exit 1 if vm.nil?
    compute.vm_reconfig_cpus('cpus' => cpu, 'instance_uuid' => vm["id"])
    compute.vm_reconfig_memory('memory' => memory_in_mb, 'instance_uuid' => vm["id"])
  end
end
