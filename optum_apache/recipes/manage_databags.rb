# Get values for Optum Apache Setup Cookbook from data_bag_item

begin
  apachevar = data_bag_item('apache', 'apache_setup')
  node.default['optum_apache']['version'] = apachevar['version']
  node.default['optum_apache']['mui_identifier'] = apachevar['mui_identifier']
  node.default['optum_apache']['environment_level'] = apachevar['environment_level'].downcase
  node.default['optum_apache']['networkzone'] = apachevar['networkzone'].downcase
rescue Net::HTTPServerException
  Chef::Log.error("Issue with data_bag_item('apache', 'apache_setup')")
end

begin
artif_cred = data_bag_item('artifactory', 'artifactory_user')
node.default['optum_apache']['artif_user'] = artif_cred['artif_user']
rescue Net::HTTPServerException
Chef::Application.fatal!("Issue with data_bag_item('artifactory', 'artifactory_user'), aborting!")
end

begin
artif_cred = data_bag_item('artifactory', 'artifactory_password', IO.read('/opt/chef-repo/data_bags_secrets/artifactory_pw_secret'))
node.default['optum_apache']['artif_password'] = artif_cred['artif_password']
rescue Net::HTTPServerException
Chef::Application.fatal!("Issue with data_bag_item('artifactory', 'artifactory_password', "\
"IO.read('/opt/chef-repo/data_bags_secrets/artifactory_pw_secret), aborting!")
end

# code review comments from Vaibhav 20171205:
# Reload attributes so that derived attributes have correct values
ruby_block 'reload_attribute_files' do
  block do
    node.from_file(run_context.resolve_attribute("#{cookbook_name}", 'default'))
  end
end
