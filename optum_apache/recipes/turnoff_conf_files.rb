# Cookbook Name:: optum_apache
# Recipe:: turnoff_conf_files
#
# Copyright (C) 2017 Optum Technology
#
# All rights reserved - Do Not Redistribute
#

# Turn off files in conf.d - 'ssl.conf', 'welcome.conf', 'userdir.conf'
ruby_block 'Turn off files in conf.d' do
  block do
    if node['optum_apache']['version'] == '2.4'
      confs_to_rename = ['ssl.conf', 'welcome.conf', 'userdir.conf']
    elsif node['optum_apache']['version'] == '2.2'
      confs_to_rename = ['ssl.conf', 'welcome.conf']
    end
    Dir.glob("#{node['optum_apache']['apache_server_httpd_confd']}/*.conf").each do |i|
      if confs_to_rename.include?(File.basename(i))
        File.rename(i, i.gsub(%r{(.*).conf}, '\\1.conf.OFF'))
      end
    end
  end
end

if node['optum_apache']['version'] == '2.4'
  # Turn off files in conf.modules.d and update 00-mpm.conf and 00-base.conf using template
  ruby_block 'Turn off files in conf.modules.d' do
    block do
      confs_not_rename = ['00-mpm.conf', '00-base.conf', '00-proxy.conf', '01-ldap.conf']
      Dir.glob("#{node['optum_apache']['apache_server_httpd_confmodulesd']}/*.conf").each do |i|
        # Chef::Log.info(i)
        next if confs_not_rename.include?(File.basename(i.to_s))
        File.rename(i, i.gsub(%r{(.*).conf}, '\\1.conf.OFF'))
      end
    end
  end

# end of 2.4 specific code
elsif node['optum_apache']['version'] == '2.2'

  # Copy httpd to httpd.prefork

  bash 'Copy httpd to httpd.prefork' do
    code <<-EOL
    cp -v "#{node['optum_apache']['apache_server_root']}/sbin/httpd" "#{node['optum_apache']['apache_server_root']}/sbin/httpd.prefork"
    if [ $? -ne 0 ]; then
       echo "Copy httpd failed. Install Unsuccessful"
       exit 11
    fi
    EOL
  end

  # Copy httpd.worker to httpd

  bash 'Copy httpd.worker to httpd' do
    code <<-EOL
    cp -v "#{node['optum_apache']['apache_server_root']}/sbin/httpd.worker" "#{node['optum_apache']['apache_server_root']}/sbin/httpd"
    if [ $? -ne 0 ]; then
       echo "Copy httpd.worker failed. Install Unsuccessful"
       exit 11
    fi
    EOL
  end
end
