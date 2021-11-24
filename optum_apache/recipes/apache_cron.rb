#
# Cookbook:: optum_apache
# Recipe:: apache_cron
# Description: Set up apache cron jobs for health check and log archive
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Restart crond service

service 'crond' do
  action :restart
end

# profile_name will be replaced depending on apache version.
# 0,10,20,30,40,50 * * * * /home/aemadmin/dce/scripts/svc_health.sh -st -i ebzdev_svchealth.input jws >/dev/null 2>&1

cron 'optum_apache: Apache Health Check every 10min' do
  command "#{node['optum_apache']['aemadmin_operational_scripts_dir']}/#{node['optum_apache']['apache_health_script']} -st -i #{node['optum_apache']['apache_health_input']} #{node['optum_apache']['profile_name']} > /dev/null 2>&1"
  minute '0,10,20,30,40,50'
  user node['optum_apache']['apache_user']
end

# Clean up and archive log files  - Daily with 7 day log retention
# 0 1 * * * /home/aemadmin/dce/scripts/log_archive.sh -tgi log_archive.input -d 7

cron 'optum_apache: Clean up and archive log files - Daily with 7 day log retention' do
  command "#{node['optum_apache']['aemadmin_operational_scripts_dir']}/#{node['optum_apache']['apache_archive_script']} -Rtgi #{node['optum_apache']['apache_log_archive_input']} -d 7"
  minute '0'
  hour '1'
  user node['optum_apache']['apache_user']
end
