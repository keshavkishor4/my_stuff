#
# Cookbook Name:: optum_apache
# Recipe:: default
#
# Copyright (C) 2017 Optum Technology
#
# All rights reserved - Do Not Redistribute
#

#--------- test data w/o databag ----------------------

# Supports apache version 2.2 and 2.4
# node.default['optum_apache']['version'] = '2.2'

# Define unique 3 character identifier
# node.default['optum_apache']['mui_identifier'] = 'bb8'

# Define environment level (dev, test, stage, prod)
# node.default['optum_apache']['environment_level'] = 'dev'

# network zone - intranet/core or internet/DMZ
# node.default['optum_apache']['networkzone'] = 'intranet'

#--------- end of test data session ----------------------

include_recipe "#{cookbook_name}::manage_databags"

# # load attributes ## #

Chef::Log.info(node.default['optum_apache']['version'])

if node['optum_apache']['version'] == '2.4'

  # apache 2.4 only suportted on RHEL7
  if node['platform_version'].to_s.to_i < 7
    Chef::Log.info("Platform version is #{node['platform_version']}")
    raise "Unsupported platform version #{node.default['optum_apache']['rhel_version']}."
  end
  node.default['optum_apache']['profile_name'] = 'apache'

  node.default['optum_apache']['apache_short_version_nodot'] = '24'
  node.default['optum_apache']['apache_short_version'] = '2.4'

  node.default['optum_apache']['package_url'] = "https://#{node['optum_apache']['artif_user']}:#{node['optum_apache']['artif_password']}@repo1.uhc.com/artifactory/chef-artifacts/optum-jboss/apache_jboss-2.4/jbcs-httpd24-httpd-2.4.23-RHEL7-x86_64.zip"
  node.default['optum_apache']['checksum'] = '5fe2e29eac5231286207f094cc18bb5d8f6ec1a3b3b962d3fc01b9d46715ac8d'
  # the following two lines need to comment out if using ark
  node.default['optum_apache']['apache_binary_path_temp'] = '/tmp/jbcs-httpd24-httpd-2.4.23-RHEL7-x86_64.zip'
  Chef::Log.info("Binary Temp Path is #{node['optum_apache']['apache_binary_path_temp']}")
  node.default['optum_apache']['apache_binary_name'] = 'jbcs-httpd24-2.4'
  # /ebiz/install/jbcs-httpd24-2.4/
  node.default['optum_apache']['apache_version_install_dir'] = "#{node['optum_apache']['apache_install_dir']}/#{node['optum_apache']['apache_binary_name']}"
  node.default['optum_apache']['apache_html_error_dir'] = "#{node['optum_apache']['apache_version_install_dir']}/httpd/www/html/error"
  # end of 2.4
elsif node['optum_apache']['version'] == '2.2'
  node.default['optum_apache']['profile_name'] = 'jws'

  node.default['optum_apache']['package_url'] = "https://#{node['optum_apache']['artif_user']}:#{node['optum_apache']['artif_password']}@repo1.uhc.com/artifactory/chef-artifacts/optum-jboss/apaws_jboss-2.2/jboss-ews-httpd-2.1.0-RHEL7-x86_64.zip"
  # node.default['optum_apache']['checksum'] = '627773f1798623eb599bbf7d39567f60941a706dc971c17f5232ffad028bc6f4'
  node.default['optum_apache']['web_connectors_package_url'] = "https://#{node['optum_apache']['artif_user']}:#{node['optum_apache']['artif_password']}@repo1.uhc.com/artifactory/chef-artifacts/optum-jboss/apaws_jboss-2.2/jboss-eap-native-webserver-connectors-6.4.0-RHEL7-x86_64.zip"
  # feng added for future use - node.default['optum_apache']['web_connector_checksum']
  node.default['optum_apache']['apache_binary_name'] = 'jboss-ews-2.1'
  node.default['optum_apache']['apache_short_version_nodot'] = ''
  node.default['optum_apache']['apache_short_version'] = '2.2'
  node.default['optum_apache']['apache_version_install_dir'] = "#{node['optum_apache']['apache_install_dir']}/#{node['optum_apache']['apache_binary_name']}"
  node.default['optum_apache']['apache_html_error_dir'] = "#{node['optum_apache']['apache_version_install_dir']}/httpd/www/html/error"
  node.default['optum_apache']['web_connectors_version_install_dir'] = "#{node['optum_apache']['apache_install_dir']}/jboss-eap-6.4"
  node.default['optum_apache']['web_connectors_modules_dir'] = "#{node['optum_apache']['apache_version_install_dir']}/httpd/modules"
  # the following two lines need to comment out if using ark
  node.default['optum_apache']['apache_binary_path_temp'] = "/tmp/apaws-jboss-#{node['optum_apache']['version']}.zip"
  node.default['optum_apache']['web_connectors_binary_path_temp'] = "/tmp/web-connectors-apaws-#{node['optum_apache']['version']}.zip"

  # feng - Soma to check if the html error file dir dce is correct
  node.default['optum_apache']['source_path'] = "#{node['optum_apache']['apache_install_dir']}/jboss-ews-2.1/httpd"
else
  raise 'Unsupported application version.'
end

# ---------------- install directories -----------------------------------------
node.default['optum_apache']['ws_server'] = 'httpd'
node.default['optum_apache']['apache_home'] = "/ebiz/#{node['optum_apache']['profile_name']}"
node.default['optum_apache']['apache_log_dir'] = "/ebiz/app_logs/#{node['optum_apache']['profile_name']}/httpd/logs"

node.default['optum_apache']['apache_server_root'] = "#{node['optum_apache']['apache_home']}/#{node['optum_apache']['ws_server']}"
node.default['optum_apache']['apache_server_httpd_conf'] = "#{node['optum_apache']['apache_server_root']}/conf"
node.default['optum_apache']['apache_server_httpd_confd'] = "#{node['optum_apache']['apache_server_root']}/conf.d"
node.default['optum_apache']['apache_server_httpd_confmodulesd'] = "#{node['optum_apache']['apache_server_root']}/conf.modules.d"
node.default['optum_apache']['apache_server_httpd_sbin'] = "#{node['optum_apache']['apache_server_root']}/sbin"
node.default['optum_apache']['apache_server_httpd_bin']  = "#{node['optum_apache']['apache_server_root']}/bin"

node.default['optum_apache']['apache_server_runtime_dir'] = "#{node['optum_apache']['apache_server_root']}/run"
node.default['optum_apache']['apache_server_pidfile'] = "#{node['optum_apache']['apache_server_root']}/run/httpd.pid"
node.default['optum_apache']['profile_file_name'] = ".profile_#{node['optum_apache']['profile_name']}"

# ---------------- httpd configuration template constants ----------------------
node.default['optum_apache']['mc_listen_port'] = '6666'
node.default['optum_apache']['listen_port'] = '1080'
node.default['optum_apache']['managerbalancername'] = 'my-cluster'
node.default['optum_apache']['documentroot'] = "#{node['optum_apache']['apache_server_root']}/www/html"

node.default['optum_apache']['was_admin_ebiz'] = 'WAS_ADMIN_eBiz'
node.default['optum_apache']['mod_cluster_auth'] = 'ModCluster Auth'
node.default['optum_apache']['eap_rtid'] = 'eaptestrtid2'

# intra net/core ldap configuration
if node['optum_apache']['networkzone'] == 'intranet'

  node.default['optum_apache']['ldap_server_host_name'] = 'ad-ldap-prod.uhc.com'
  node.default['optum_apache']['ldap_server_port'] = '389'
  node.default['optum_apache']['ldap_basedn'] = 'dc=ms,dc=ds,dc=uhc,dc=com'
  node.default['optum_apache']['ldap_binddn_users'] = 'CN=Users,DC=ms,DC=ds,DC=uhc,DC=com'

  if (node['optum_apache']['environment_level'] == 'dev' || node['optum_apache']['environment_level'] == 'test'  || node['optum_apache']['environment_level'] == 'tst')
    node.default['optum_apache']['ldap_pass_encrypted'] = '{xor}Ay0KEWltMhs='
  elsif (node['optum_apache']['environment_level'] == 'stg' || node['optum_apache']['environment_level'] == 'stage'|| node['optum_apache']['environment_level'] == 'prod')
    node.default['optum_apache']['ldap_pass_encrypted'] = '{xor}Aw0qMWltEjs='
  else
    raise 'Unsupported environment level.'
  end

# inter net/DMZ ldap configuration
elsif node['optum_apache']['networkzone'] == 'internet'

  node.default['optum_apache']['ldap_server_host_name'] = 'ad-ldap-prod-dmzmgmt.uhc.com'
  node.default['optum_apache']['ldap_server_port'] = '636'
  node.default['optum_apache']['ldap_basedn'] = 'dc=dmzmgmt,dc=uhc,dc=com'
  node.default['optum_apache']['ldap_binddn_users'] = 'CN=Users,DC=ms,DC=ds,DC=uhc,DC=com'

  if (node['optum_apache']['environment_level'] == 'dev' || node['optum_apache']['environment_level'] == 'test'  || node['optum_apache']['environment_level'] == 'tst')
    node.default['optum_apache']['ldap_pass_encrypted'] = '{xor}Ay0KEWltMhs='
    node.default['optum_apache']['eap_rtid'] = 'eaptestrtid2'
  elsif (node['optum_apache']['environment_level'] == 'stg' || node['optum_apache']['environment_level'] == 'stage'|| node['optum_apache']['environment_level'] == 'prod')
    node.default['optum_apache']['ldap_pass_encrypted'] = '{xor}Aw0qMWltEjs='
    node.default['optum_apache']['eap_rtid'] = 'eapprodrtid2'
  else
    raise 'Unsupported environment level.'
  end
else
  raise 'Unsupported network zone.'
end

# for AuthLDAPBindPassword in conf files
node.default['optum_apache']['ldap_pass_decrypted'] = "exec:/ebiz/apache/httpd/bin/waspass #{node['optum_apache']['ldap_pass_encrypted']}"

# ---------------- attributes for apache cron job setup ------------------------
node.default['optum_apache']['aemadmin_home'] = '/home/aemadmin'
node.default['optum_apache']['aemadmin_operational_scripts_dir'] = '/home/aemadmin/dce/scripts'
node.default['optum_apache']['aemadmin_operational_input_dir'] = '/home/aemadmin/dce/input'
node.default['optum_apache']['apache_restart_script'] = 'bounce_ews.sh'
node.default['optum_apache']['apache_archive_script'] = 'log_archive.sh'
node.default['optum_apache']['apache_health_script'] = 'svc_health.sh'
node.default['optum_apache']['apache_health_input'] = "#{node['optum_apache']['mui_identifier']}#{node['optum_apache']['environment_level']}_svchealth.input"
node.default['optum_apache']['apache_log_archive_input'] = 'log_archive.input'

# ----------------  attributes for apachectl custimization ---------------------
# US811665 Customize apachectl to resolve potential conflict between optum_apache cookbook and redhat postinstall script
node.default['optum_apache']['apachect_file_name'] = 'apachectl'
# the path to httpd binary, including options if necessary '/ebiz/apache/httpd/sbin/httpd'
node.default['optum_apache']['httpd_binary_path'] = "#{node['optum_apache']['apache_server_httpd_sbin']}/httpd"
# the options for httpd command "-f /ebiz/apache/httpd/conf/httpd.conf -E /ebiz/apache/httpd/logs/httpd.log"
# node.default['optum_apache']['apachectl_options'] = "-f #{node['optum_apache']['apache_server_httpd_conf']}/httpd.conf -E #{node['optum_apache']['apache_log_dir']}/httpd.log"
# the library path /ebiz/apache/httpd/lib:$LD_LIBRARY_PATH
node.default['optum_apache']['apache_lib_path'] = "#{node['optum_apache']['apache_server_root']}/lib:$LD_LIBRARY_PATH"

# Prerequisites:o	Openssl, Ldap, apr, gdb/pstack,
include_recipe 'optum_apache::pre_install'

# create filesystems/directories
include_recipe 'optum_apache::create_dir'

# install JBoss Web Server binaries
include_recipe 'optum_apache::install_binaries'

# Turnoff conf files
include_recipe 'optum_apache::turnoff_conf_files'

# generate configuration files/scripts from templates
if node['optum_apache']['version'] == '2.2'
  include_recipe 'optum_apache::generate_22_templates'
elsif node['optum_apache']['version'] == '2.4'
  include_recipe 'optum_apache::generate_24_templates'
end

# generate cron job input files
include_recipe 'optum_apache::generate_cron_input'

# Customize apachectl script to resolve the conflict with conf.modules.d
if node['optum_apache']['version'] == '2.4'
  include_recipe 'optum_apache::generate_apachectl'
end

# set up apache cron jobs
include_recipe 'optum_apache::apache_cron'

# set permissions on apache install and config directories
# include_recipe 'optum_apache::set_permissions'

include_recipe 'optum_apache::post_install'

# export the node attributes for integration testing
include_recipe 'optum_apache::export_node'
