#
# Cookbook:: optum_apache
# Recipe:: generate_24_templates
# Description: generate html error pages, httpd configurations and apache profile
#
# Copyright:: 2017, The Authors, All Rights Reserved.

#------------------ generate html error pages ----------------------------
error_dir = node['optum_apache']['apache_html_error_dir']
temp_dir = "#{node['optum_apache']['apache_short_version']}/www_html_error"

# /ebiz/install/jbcs-httpd24-2.4/httpd/www/html/error
directory node['optum_apache']['apache_html_error_dir'].to_s do
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  recursive true
end

template "#{error_dir}/403.html" do
  source "#{temp_dir}/403_html.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
end

template "#{error_dir}/404.html" do
  source "#{temp_dir}/404_html.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
end

template "#{error_dir}/500.html" do
  source "#{temp_dir}/500_html.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
end

# ---------------- generate httpd configurations and apache profile ------------------------
temp_dir = "#{node['optum_apache']['apache_short_version']}/httpd_confs"

# /ebiz/apache/httpd/conf/httpd.conf
target_dir = node['optum_apache']['apache_server_httpd_conf']

template "#{target_dir}/httpd.conf" do
  source "#{temp_dir}/httpd_conf.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  variables(
    server_root: node['optum_apache']['apache_server_root'],
    server_pidfile: node['optum_apache']['apache_server_pidfile'],
    host_fqdn: node['optum_apache']['host_fqdn'],
    listen_port: node['optum_apache']['listen_port'],
    log_location: node['optum_apache']['apache_log_dir'],
    documentroot: node['optum_apache']['documentroot'],
    was_admin_ebiz: node['optum_apache']['was_admin_ebiz'],
    eap_rtid: node['optum_apache']['eap_rtid'],
    ldap_binddn_users: node['optum_apache']['ldap_binddn_users'],
    # ldap_pass_encrypted: node['optum_apache']['ldap_pass_encrypted'],
    ldap_pass_decrypted: node['optum_apache']['ldap_pass_decrypted'],
    ldap_server_host_name: node['optum_apache']['ldap_server_host_name'],
    ldap_server_port: node['optum_apache']['ldap_server_port']
  )
end

template "#{target_dir}/httpd.conf-dontlog" do
  source "#{temp_dir}/httpd_conf_dontlog.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
end

template "#{target_dir}/url_management.conf" do
  source "#{temp_dir}/url_management_conf.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
end

target_dir = node['optum_apache']['apache_server_httpd_confd']

template "#{target_dir}/mod_cluster.conf" do
  source "#{temp_dir}/mod_cluster_conf.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  variables(
    server_root: node['optum_apache']['apache_server_root'],
    host_fqdn: node['optum_apache']['host_fqdn'],
    log_location: node['optum_apache']['apache_log_dir'],
    mc_listen_port: node['optum_apache']['mc_listen_port'],
    was_admin_ebiz: node['optum_apache']['was_admin_ebiz'],
    mod_cluster_auth: node['optum_apache']['mod_cluster_auth'],
    eap_rtid: node['optum_apache']['eap_rtid'],
    ldap_binddn_users: node['optum_apache']['ldap_binddn_users'],
    # ldap_pass_encrypted: node['optum_apache']['ldap_pass_encrypted'],
    ldap_pass_decrypted: node['optum_apache']['ldap_pass_decrypted'],
    ldap_server_host_name: node['optum_apache']['ldap_server_host_name'],
    ldap_server_port: node['optum_apache']['ldap_server_port']
  )
end

# conf.modules.d - copy 00-mpm.conf, 00-base.conf and 00-proxy.conf. The other files are turned off using turnoff_conf_files.rb
target_dir = node['optum_apache']['apache_server_httpd_confmodulesd']

template "#{target_dir}/00-mpm.conf" do
  source "#{temp_dir}/00_mpm_conf.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
end

template "#{target_dir}/00-base.conf" do
  source "#{temp_dir}/00_base_conf.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  variables(
    server_runtime_dir: node['optum_apache']['apache_server_runtime_dir']
  )
end

template "#{target_dir}/00-proxy.conf" do
  source "#{temp_dir}/00_proxy_conf.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
end

# ----------------- generate apache profile .profie_apache------------------
# feng to do check if the /home/aemadmin exist
temp_dir = node['optum_apache']['apache_short_version']

template "#{node['optum_apache']['aemadmin_home']}/#{node['optum_apache']['profile_file_name']}" do
  source "#{temp_dir}/dot_profile_apache.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  variables(
    profile_name: node['optum_apache']['profile_name'],
    environment_level: node['optum_apache']['environment_level'],
    mui_identifier: node['optum_apache']['mui_identifier'],
    server_root: node['optum_apache']['apache_server_root'],
    apache_log_dir: node['optum_apache']['apache_log_dir']
    # release_ver: node['optum_apache']['version']
  )
end
