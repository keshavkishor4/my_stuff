## optum_apache - available attributes

# ---------------- Set the hostname to the system hostname ---------------------
node.default['optum_apache']['host_name'] = node['hostname']
node.default['optum_apache']['host_fqdn'] = node['fqdn']

# ---------------- use root for dev testing if needed --------------------------
node.default['optum_apache']['apache_user'] = 'aemadmin'
node.default['optum_apache']['apache_group'] = 'dce'
node.default['optum_apache']['apache_mode'] = '750'

# ---------------- common install directories ----------------------------------
node.default['optum_apache']['apache_install_dir'] = '/ebiz/install'
node.default['optum_apache']['aemadmin_home'] = '/home/aemadmin'

# determine version of RHEL for package location and name
if node['platform_version'].to_s.to_i < 7
  node.default['optum_apache']['rhel_version'] = 'RHEL6-x86_64'
elsif node['platform_version'].to_s.to_i >= 7
  node.default['optum_apache']['rhel_version'] = 'RHEL7-x86_64'
end

Chef::Log.info(node.default['optum_apache']['rhel_version'])
