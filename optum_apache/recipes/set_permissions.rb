#
# Cookbook:: optum_apache
# Recipe:: set_permissions
#
# Copyright:: 2017, The Authors, All Rights Reserved.

directory '/ebiz' do
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  recursive true
end
