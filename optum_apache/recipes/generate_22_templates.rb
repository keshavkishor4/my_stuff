# Cookbook Name:: optum_apache
# Recipe:: generate_from_templates
#
# Copyright (C) 2017 Optum Technology
#
# All rights reserved - Do Not Redistribute
#

template "#{node['optum_apache']['apache_server_httpd_conf']}/httpd.conf" do
  source "#{node['optum_apache']['version']}/httpd/conf/httpd.conf.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  variables(
    server_root: node['optum_apache']['apache_server_root'],
    server_name: node['optum_apache']['host_name'],
    host_fqdn: node['optum_apache']['host_fqdn'], 
    listen_port: node['optum_apache']['listen_port'],
    log_location: node['optum_apache']['apache_log_dir'],
    ldap_server_host_name: node['optum_apache']['ldap_server_host_name'],
    ldap_server_port: node['optum_apache']['ldap_server_port']
  )
end

template "#{node['optum_apache']['apache_home']}/httpd/conf/httpd.conf-dontlog" do
  source "#{node['optum_apache']['version']}/httpd/conf/httpd.conf-dontlog.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
end

template "#{node['optum_apache']['apache_home']}/httpd/conf/url_management.conf" do
  source "#{node['optum_apache']['version']}/httpd/conf/url_management.conf.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
end

template "#{node['optum_apache']['apache_home']}/httpd/conf.d/mod_cluster.conf" do
  source "#{node['optum_apache']['version']}/httpd/conf.d/mod_cluster.conf.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  variables(
    server_root: node['optum_apache']['apache_server_root'],
    server_name: node['optum_apache']['host_name'],
    host_fqdn: node['optum_apache']['host_fqdn'],
    listen_port: node['optum_apache']['listen_port'],
    log_location: node['optum_apache']['apache_log_dir'],
    ldap_server_host_name: node['optum_apache']['ldap_server_host_name'],
    ldap_server_port: node['optum_apache']['ldap_server_port'],
    mc_listen_port: node['optum_apache']['mc_listen_port']
  )
end

# Create the apaws error directory
directory node['optum_apache']['apache_html_error_dir'] do
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  recursive true
end

template "#{node['optum_apache']['apache_html_error_dir']}/403.html" do
  source "#{node['optum_apache']['version']}/dce/error/403.html.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
end

template "#{node['optum_apache']['apache_html_error_dir']}/404.html" do
  source "#{node['optum_apache']['version']}/dce/error/404.html.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
end

template "#{node['optum_apache']['apache_html_error_dir']}/500.html" do
  source "#{node['optum_apache']['version']}/dce/error/500.html.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
end

template "#{node['optum_apache']['aemadmin_home']}/.profile_jws" do
  source "#{node['optum_apache']['version']}/dce/profile_jws.erb"
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  variables(
    mui: node['optum_apache']['mui_identifier'],
    release_env: node['optum_apache']['environment_level'],
    server_root: node['optum_apache']['apache_server_root'],
    release_ver: node['optum_apache']['version']
  )
end
