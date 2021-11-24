# Cookbook Name:: optum_apache
# Recipe:: install_binaries_ark
#
# Copyright (C) 2017 Optum Technology
#
# All rights reserved - Do Not Redistribute
#

# Source Apache package from Artifactory and unpack it
ark node['optum_apache']['apache_binary_name'] do
  url lazy { node['optum_apache']['package_url'] }
  path lazy { node['optum_apache']['apache_install_dir'] }
  checksum node['optum_apache']['checksum']
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  strip_components 1
  action :put
end

if node['optum_apache']['version'] == '2.2'

  # Source web connector package from Artifactory and unpack it
  ark node['optum_apache']['apache_binary_name'] do
    url lazy { node['optum_apache']['web_connectors_package_url'] }
    path lazy { node['optum_apache']['web_connectors_version_install_dir'] }
    owner node['optum_apache']['apache_user']
    group node['optum_apache']['apache_group']
    mode node['optum_apache']['apache_mode']
    strip_components 1
    action :put
  end

  # create folder httpd/modules
  directory node['optum_apache']['web_connectors_modules_dir'] do
    owner node['optum_apache']['apache_user']
    group node['optum_apache']['apache_group']
    mode  node['optum_apache']['apache_mode']
    recursive true
  end

  ruby_block 'Copy Web Connectors Modules files' do
    block do
      ::FileUtils.cp_r "#{node['optum_apache']['web_connectors_version_install_dir']}/modules/system/layers/base/native/lib64/httpd/modules/.", node['optum_apache']['web_connectors_modules_dir'].to_s
    end
  end
end # end of 2.2 spcific code

# change permissions. ark didn't set it recursively
#execute 'chmod-apache-install' do
#  command "/bin/chmod -R #{node['optum_apache']['apache_mode']} #{node['optum_apache']['apache_install_dir']}/"
#end

# change owner
#execute 'chown-apache-install' do
#  command "/bin/chown -R #{node['optum_apache']['apache_user']}:#{node['optum_apache']['apache_group']} #{node['optum_apache']['apache_install_dir']}/"
#end

#  Link the install path apache_home </ebiz/apcahe<or jws>> back to install version dir
link node['optum_apache']['apache_home'] do
  to node['optum_apache']['apache_version_install_dir']
  link_type :symbolic
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
end

# feng to do - review if it is also required for 2.2
cookbook_file 'waspass script to apache bin' do
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  path "#{node['optum_apache']['apache_server_httpd_bin']}/waspass"
  source '/bin/waspass'
end
