# Cookbook Name:: optum_apache
# Recipe:: install_binaries
#
# Copyright (C) 2017 Optum Technology
#
# All rights reserved - Do Not Redistribute
#

# Download the package
remote_file node['optum_apache']['apache_binary_path_temp'] do
  source node['optum_apache']['package_url']
  checksum node['optum_apache']['checksum']
end

# Unzip the package
execute 'unzip_package' do
  command "/usr/bin/unzip -oq #{node['optum_apache']['apache_binary_path_temp']} -d #{node['optum_apache']['apache_install_dir']}"
  # potentially remove this if it gives issues
  #  not_if { File.exist?(node['optum_apache']['apache_install_dir']) }
  # error_message "Unzip JBOSS Apache Binaries failed. Install Unsuccessful"
end

if node['optum_apache']['version'] == '2.2'

  # Download the package
  remote_file node['optum_apache']['web_connectors_binary_path_temp'] do
    source node['optum_apache']['web_connectors_package_url']
    checksum node['optum_apache']['web_connector_checksum']
  end

  # Unzip the package
  # Soma to validate the connector install dir below.
  execute 'unzip_package' do
    command "/usr/bin/unzip -o #{node['optum_apache']['web_connectors_binary_path_temp']} -d #{node['optum_apache']['apache_install_dir']}"
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
end   # end of 2.2 spcific code

# change owner
execute 'chown-apache-install' do
  command "/bin/chown -R #{node['optum_apache']['apache_user']}:#{node['optum_apache']['apache_group']} #{node['optum_apache']['apache_install_dir']}/"
end

# change permissions
execute 'chmod-apache-install' do
  command "/bin/chmod -R #{node['optum_apache']['apache_mode']} #{node['optum_apache']['apache_install_dir']}/"
end

#  Link the install path apache_home </ebiz/apcahe<or jws>> back to install version dir
link node['optum_apache']['apache_home'] do
  to node['optum_apache']['apache_version_install_dir']
  link_type :symbolic
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  # not_if { node['optum_apache']['apache_home'] == node['optum_apache']['apache_version_install_dir'] }
end

# clean up tmp location of files
execute 'remove_temp_binary_file' do
  command "rm -f #{node['optum_apache']['apache_binary_path_temp']}"
end

execute 'remove_temp_binary_file' do
  command "rm -f #{node['optum_apache']['web_connectors_binary_path_temp']}"
end

# feng to do - review if it is also required for 2.2
# if node['optum_apache']['version'] == '2.4'
cookbook_file 'waspass script to apache bin' do
  owner node['optum_apache']['apache_user']
  group node['optum_apache']['apache_group']
  mode node['optum_apache']['apache_mode']
  path "#{node['optum_apache']['apache_server_httpd_bin']}/waspass"
  source '/bin/waspass'
end
# end
