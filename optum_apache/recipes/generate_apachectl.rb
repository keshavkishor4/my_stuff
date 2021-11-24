#
# Cookbook:: optum_apache
# Recipe:: generate_apachectl
# Description: generate apachectl scritp with customized path
# Copyright:: 2017, The Authors, All Rights Reserved.

# ----------------- customize apachectl script ------------------
# US811665 Customize apachectl to resolve the potential conflict between optum_apache cookbook and redhat postinstall script
temp_dir = node['optum_apache']['apache_short_version']

template "#{node['optum_apache']['apache_server_httpd_sbin']}/#{node['optum_apache']['apachect_file_name']}" do
  source "#{temp_dir}/apachectl.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  variables(
    httpd_binary_path: node['optum_apache']['httpd_binary_path'],
    apache_lib_path: node['optum_apache']['apache_lib_path']
  )
end
