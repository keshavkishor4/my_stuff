# Cookbook Name:: optum_apache
# Recipe:: create_dir
#
# Copyright (C) 2017 Optum Technology
#
# All rights reserved - Do Not Redistribute
#

# check the required free space

def space_check
  if node['filesystem']['/opt']['kb_available'] <= 500 * 1024 * 1024
    Chef::Log.info('Not Enough Space')
  elsif node['filesystem']['/opt']['kb_available'] >= 500 * 1024 * 1024
    Chef::Log.info('Proceed')
  end
end

# Create apache log directory structure
=begin
#For the owner, group, and mode properties, the value of this attribute applies only to the leaf directory.
directory (node['optum_apache']['apache_log_dir']).to_s do
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  recursive true
end
=end
mydir = node['optum_apache']['apache_log_dir']
[].tap { |x| Pathname(mydir).each_filename { |d| x << (x.empty? ? [d] : x.last + [d]) } }.each do |dir|
  directory File.join(dir) do
    owner node['optum_apache']['apache_user']
    group node['optum_apache']['apache_group']
    mode node['optum_apache']['apache_mode']
    recursive true
  end
end

directory node['optum_apache']['apache_install_dir'] do
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  recursive true
end

# Create aemadmin install directory. should be created by middleware cookbook
  directory node['optum_apache']['aemadmin_home'] do
    owner node['optum_apache']['apache_user']
    group node['optum_apache']['apache_group']
    mode node['optum_apache']['apache_mode']
    recursive true
  end

# feng - the dir should come from binary. To be clean up if there is no need to create this dir.
if node['optum_apache']['version'] == '2.2'
  # Create the dce directory
  directory node['optum_apache']['source_path'] do
    owner node['optum_apache']['apache_user']
    group node['optum_apache']['apache_group']
    mode node['optum_apache']['apache_mode']
    recursive true
  end
end
