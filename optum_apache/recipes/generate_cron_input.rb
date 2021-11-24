#
# Cookbook:: optum_apache
# Recipe:: generate_cron_input
# Description: generate cron job input files for svc health check and log archive
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# ----------------- generate input for cron jobs ------------------

directory node['optum_apache']['aemadmin_operational_input_dir'] do
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  recursive true
end

# /home/aemadmin/dce/input/${mui}${env}_svchealth.input for cron jobs
template "#{node['optum_apache']['aemadmin_operational_input_dir']}/#{node['optum_apache']['apache_health_input']}" do
  source 'post_install_input/svchealth_input.erb'
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  variables(
    fqdn: node['optum_apache']['host_fqdn'],
    profile_name: node['optum_apache']['profile_name'],
    apache_server_httpd_conf: node['optum_apache']['apache_server_httpd_conf'],
    aemadmin_operational_scripts_dir: node['optum_apache']['aemadmin_operational_scripts_dir'],
    apache_restart_script: node['optum_apache']['apache_restart_script']
  )
end

# Generate /home/aemadmin/dce/input/log_archive.input for cron jobs
template "#{node['optum_apache']['aemadmin_operational_input_dir']}/#{node['optum_apache']['apache_log_archive_input']}" do
  source 'post_install_input/log_archive_input.erb'
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  variables(
    apache_log_dir: node['optum_apache']['apache_log_dir'],
    fqdn: node['optum_apache']['host_fqdn']
  )
end
