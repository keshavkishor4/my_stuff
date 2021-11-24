#
# Cookbook:: optum_apache
# Recipe:: post_install
#
# Copyright:: 2017, The Authors, All Rights Reserved.

=begin
# Commented out this session because it caused conflict when starting server. Added the binary and library path to apachectl instead
# After the install and configure of the webserver, execute the post install script at /ebiz/apache/httpd/.postinstall
execute 'execute post install script' do
  cwd '/ebiz/apache/httpd'
  command '/ebiz/apache/httpd/.postinstall'
  user node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
end
=end

# run bounce_ews.sh to start the httpd after install and config
execute 'start httpd with bounce_ews.sh' do
  command "#{node['optum_apache']['aemadmin_operational_scripts_dir']}/#{node['optum_apache']['apache_restart_script']} -b #{node['optum_apache']['profile_name']}"
  user node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  environment ({'HOME' => "#{node['optum_apache']['aemadmin_home']}"})
end
