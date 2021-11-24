#
# Cookbook Name:: optum_apache
# Recipe:: export_node
#
# Copyright (C) 2017 Optum Technology
#
# All rights reserved - Do Not Redistribute
#

# converts the current node's attributes to json and
# writes it to a known location in /tmp/kitchen on the node.

directory ('/var/chef/kitchen') do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

ruby_block 'Save node attributes' do
  block do
    if Dir::exist?('/var/chef/kitchen')
      IO.write("/var/chef/kitchen/chef_node.json", node.to_json)
    end
  end
end

file '/var/chef/kitchen/chef_node.json' do
  owner 'root'
  group 'root'
  mode '0755'
end
