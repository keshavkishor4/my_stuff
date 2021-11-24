#
# Cookbook Name:: optum_apache
# Recipe:: test_configuration_files
#
# Copyright (C) 2017 Optum Technology
#
# All rights reserved - Do Not Redistribute
#
require 'json'

title 'test apache configuration files'

networkzone = attribute('networkzone', default: '<intranet or internet>', description: "networkzone of the server")

control 'apache-pre-0.0' do
  impact 1.0
  title '** Prerequisite:  Node atrribute export file should exist to provide the test data **'
  desc ' Node atrribute export file exist to provide the test data.'
  describe file('/var/chef/kitchen/chef_node.json') do
    it { should exist }
    its('mode') { should cmp '00755' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
  end
end

control 'apache-config_files-1.0' do
  impact 1.0
  title '** test .profile_apache or .profile_jws contents **'
  desc 'apache or jws profile has OPTIONS setup.'

  describe file('/home/aemadmin/.profile_apache') do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) { node['default']['optum_apache']['version'] }
    before do
      skip if version == '2.2'
    end
    it { should exist }
    its('content') { should match %r{^SERVER=apache$} }
    its('content') { should match %r{^ENV=(dev|tst|prd)$} }
    its('content') { should match %r{^MUI=\w{3,}$} }
    its('content') { should match %r{^EWS_HOME=\/ebiz\/apache\/httpd$} }
    its('content') { should match %r{^EWS_LOGS=\/ebiz\/app_logs\/apache\/httpd\/logs$} }
    its('content') { should match %r{^export EWS_OPTIONS$} }
  end

  describe file('/home/aemadmin/.profile_jws') do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) { node['default']['optum_apache']['version'] }
    before do
      skip if version == '2.4'
    end
    it { should exist }
    its('content') { should match %r{^SERVER=jws$} }
    its('content') { should match %r{^ENV=(dev|tst|prd)$} }
    its('content') { should match %r{^MUI=\w{3,}$} }
    its('content') { should match %r{^EWS_HOME=\/ebiz\/jws\/httpd$} }
    its('content') { should match %r{^EWS_LOGS=\/ebiz\/app_logs\/jws\/httpd\/logs$} }
    its('content') { should match %r{^export EWS_OPTIONS$} }
  end
end

# spin off another contro to reduce the side of the block that rubocop complains
control 'apache-config-files-2.0' do
  impact 1.0
  title '** test httpd.conf parameters **'
  desc 'test httpd.conf parameters'
  describe file('/ebiz/apache/httpd/conf/httpd.conf') do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) { node['default']['optum_apache']['version'] }
    before do
      skip if version == '2.2'
    end

    it { should exist }
    # all the parameters are parsed.
    its('content') { should_not match %r{(\<%=)} }
    its('content') { should match %r{^ServerRoot(\s"{0,1})\/ebiz\/apache\/httpd"{0,1}$} }
    its('content') { should match %r{^PidFile(\s"{0,1})\/ebiz\/apache\/httpd\/run\/httpd.pid"{0,1}$} }
    its('content') { should match %r{^Listen(\s"{0,1})(\w+\.\w{2,6})+:1080"{0,1}$} }
    its('content') { should match %r{^ServerName(\s"{0,1})(\w+\.\w{2,6})+:1080"{0,1}$} }
    its('content') { should match %r{^DocumentRoot(\s"{0,1})\/ebiz\/apache\/httpd\/www\/html"{0,1}$} }
    its('content') { should match %r{^\<Directory(\s"{0,1})\/ebiz\/apache/httpd\/www\/html"{0,1}\>$} }
    its('content') { should match %r{^ErrorLog(\s"{0,1})\/ebiz\/app_logs\/apache\/httpd\/logs\/error_log"{0,1}$} }
    its('content') { should match %r{^CustomLog(\s"{0,1})\/ebiz\/app_logs\/apache\/httpd\/logs\/access_log\scombined"{0,1}$} }
    its('content') { should match %r{^Alias\s\/icons\/(\s"{0,1})\/ebiz\/apache\/httpd\/www\/icons\/"{0,1}$} }
    its('content') { should match %r{^\<Directory(\s"{0,1})\/ebiz\/apache\/httpd\/www\/icons"{0,1}\>$} }
    its('content') { should match %r{^Alias\s\/error\/(\s"{0,1})\/ebiz\/apache\/httpd\/www\/html\/error\/"{0,1}$} }
    its('content') { should match %r{\<Directory(\s"{0,1})\/ebiz\/apache\/httpd\/www\/html"{0,1}\>$} }
  end

  describe file('/ebiz/jws/httpd/conf/httpd.conf') do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) { node['default']['optum_apache']['version'] }
    before do
      skip if version == '2.4'
    end

    it { should exist }
    # all the parameters are parsed.
    its('content') { should_not match %r{\<%=} }
    its('content') { should match %r{^ServerRoot(\s"{0,1})\/ebiz\/jws\/httpd"{0,1}\s$} }
    its('content') { should match %r{^PidFile(\s"{0,1})run\/httpd.pid"{0,1}$} }
    its('content') { should match %r{^Listen(\s"{0,1})(\w+\.\w{2,6})+:1080"{0,1}$} }
    its('content') { should match %r{^ServerName(\s"{0,1})(\w+\.\w{2,6})+:1080"{0,1}$} }
    its('content') { should match %r{^DocumentRoot(\s"{0,1})\/ebiz\/jws\/httpd\/www\/html"{0,1}$} }
    its('content') { should match %r{^\<Directory(\s"{0,1})\/ebiz\/jws\/httpd\/www\/html"{0,1}\>$} }
    its('content') { should match %r{^ErrorLog(\s"{0,1})\/ebiz\/app_logs\/jws\/httpd\/logs\/error_log"{0,1}$} }
    its('content') { should match %r{^CustomLog(\s"{0,1})\/ebiz\/app_logs\/jws\/httpd\/logs\/access_log\scombined\senv=!dontlog"{0,1}$} }
    its('content') { should match %r{^Alias\s\/icons\/(\s"{0,1})\/ebiz\/jws\/httpd\/www\/icons\/"{0,1}$} }
    its('content') { should match %r{^\<Directory(\s"{0,1})\/ebiz\/jws\/httpd\/www\/icons"{0,1}\>$} }
    its('content') { should match %r{^Alias\s\/error\/(\s"{0,1})\/ebiz\/jws\/httpd\/www\/html\/error\/"{0,1}$} }
    its('content') { should match %r{^\<Directory(\s"{0,1})\/ebiz\/jws\/httpd\/www\/html"{0,1}\>$} }
  end
end

# spin off another control to reduce the size of the block that rubocop complains
control 'apache-config-files-2.1' do
  impact 1.0
  title '** test httpd.conf LDAP parameters for 2.4**'
  desc 'test httpd.conf LDAP parameters for 2.4'
  describe file('/ebiz/apache/httpd/conf/httpd.conf') do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) { node['default']['optum_apache']['version'] }
    before do
      skip if version == '2.2'
    end

    its('content') { should match %r{AuthName(\s"{0,1})WAS_ADMIN_eBiz"{0,1}$} }
    its('content') { should match %r{AuthLDAPBindDN(\s"{0,1})CN=eaptestrtid2,CN=Users,DC=ms,DC=ds,DC=uhc,DC=com"{0,1}$} }
    its('content') { should match %r{require(\s"{0,1})ldap-group\sCN=WAS_ADMIN_eBiz,CN=Users,DC=ms,DC=ds,DC=uhc,DC=com"{0,1}$} }
    its('content') { should match %r{AuthLDAPBindPassword(\s"{0,1})exec\:\/ebiz\/apache\/httpd\/bin\/waspass\s({xor}Ay0KEWltMhs=|{xor}Aw0qMWltEjs=)"{0,1}$} }
  end

#   describe file('/ebiz/jws/httpd/conf/httpd.conf') do
#     let(:node) { json('/var/chef/kitchen/chef_node.json').params }
#     let(:version) {node['default']['optum_apache']['version']}
#     before do
#       skip if version == '2.4'
#     end
#     # feng to do - check if LDAP need to be configured for 2.2. Currently commented out in httpd.conf
#     its('content') { should match %r{AuthName(\s"{0,1})WAS_ADMIN_eBiz$} }
#     its('content') { should match %r{AuthLDAPBindDN(\s"{0,1})CN=eaptestrtid2,CN=Users,DC=ms,DC=ds,DC=uhc,DC=com"{0,1}$} }
#     its('content') { should match %r{require(\s"{0,1})ldap-group\sCN=WAS_ADMIN_eBiz,CN=Users,DC=ms,DC=ds,DC=uhc,DC=com"{0,1}$} }
#     its('content') { should match %r{AuthLDAPBindPassword(\s"{0,1})exec\:\/ebiz\/jws\/httpd\/bin\/waspass\s({xor}Ay0KEWltMhs=|{xor}Aw0qMWltEjs=)"{0,1}$} }
#   end
end

control 'apache-config-files-3.0' do
  impact 1.0
  title '** test mod_cluster.conf parameters **'
  desc 'test httpd.conf parameters'
  describe file('/ebiz/apache/httpd/conf.d/mod_cluster.conf') do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) { node['default']['optum_apache']['version'] }
    before do
      skip if version == '2.2'
    end

    it { should exist }
    its('content') { should_not match %r{\<%=} }
    its('content') { should match %r{^MemManagerFile(\s"{0,1})\/ebiz\/apache\/httpd\/cache\/mod_cluster"{0,1}$} }
    its('content') { should match %r{^Listen(\s"{0,1})[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}:6666"{0,1}$} }
    its('content') { should match %r{\<VirtualHost(\s(\w+\.\w{2,6})+:6666\>$)} }
  end

  describe file("/ebiz/jws/httpd/conf.d/mod_cluster.conf") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.4'
    end

    it { should exist }
    its('content') { should_not match %r{\<%=} }
    # its('content') { should match %r{^Listen(\s"{0,1})(\w+\.\w{2,6})+:6666"{0,1}$} }
    # feng to do - failed for 2.2
    its('content') { should match %r{^Listen(\s"{0,1})[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}:6666"{0,1}$} }
    # feng to do - failed for 2.2
    its('content') { should match %r{\<VirtualHost(\s(\w+\.\w{2,6})+:6666\>$)} }
  end
end

# need to review the dmz ldap config with Manjot
control 'apache-config-files-3.1' do
  impact 1.0
  title '** test mod_cluster.conf LDAP parameters for 2.4 **'
  desc 'test mod_cluster.conf LDAP parameters for 2.4'
  describe file("/ebiz/apache/httpd/conf.d/mod_cluster.conf") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    let(:networkzone) {node['default']['optum_apache']['networkzone']}
    before do
      skip if version == '2.2'
    end

    its('content') { should match %r{AuthName(\s"{0,1})ModCluster\sAuth"{0,1}$} }
    its('content') { should match %r{AuthLDAPBindDN(\s"{0,1})CN=eaptestrtid2,CN=Users,DC=ms,DC=ds,DC=uhc,DC=com"{0,1}$} }
    its('content') { should match %r{AuthLDAPBindPassword(\s"{0,1})exec\:\/ebiz\/apache\/httpd\/bin\/waspass\s({xor}Ay0KEWltMhs=|{xor}Aw0qMWltEjs=)"{0,1}$} }
    its('content') { should match %r{Require(\s"{0,1})ldap-group\sCN=WAS_ADMIN_eBiz,CN=Users,DC=ms,DC=ds,DC=uhc,DC=com"{0,1}$} }

    if networkzone == 'intranet'
      its('content') { should match %r{AuthLDAPUrl(\s"{0,1})ldap:\/\/ad-ldap-prod.uhc.com:389\/CN=Users,dc=ms,dc=ds,dc=uhc,dc=com\?cn"{0,1}$} }
    elsif networkzone == 'internet'
      its('content') { should match %r{AuthLDAPUrl(\s"{0,1})ldap:\/\/ad-ldap-prod-dmzmgmt.uhc.com:636\/CN=Users,dc=ms,dc=ds,dc=uhc,dc=com\?cn"{0,1}$} }
    else
      raise 'Unsupported network zone.'
    end
  end
  # Feng to do - check if applicable to 2.2. It is commented out in 2.2 httpd.conf
  # describe file("/ebiz/jws/httpd/conf.d/mod_cluster.conf") do
  #   let(:node) { json('/var/chef/kitchen/chef_node.json').params }
  #   let(:version) {node['default']['optum_apache']['version']}
  #   let(:networkzone) {node['default']['optum_apache']['networkzone']}
  #   before do
  #     skip if version == '2.4'
  #   end
  #
  #   its('content') { should match %r{AuthName(\s"{0,1})ModCluster\sAuth"{0,1}$} }
  #   its('content') { should match %r{AuthLDAPBindDN(\s"{0,1})CN=eaptestrtid2,CN=Users,DC=ms,DC=ds,DC=uhc,DC=com"{0,1}$} }
  #   its('content') { should match %r{AuthLDAPBindPassword(\s"{0,1})exec\:\/ebiz\/jws\/httpd\/bin\/waspass\s({xor}Ay0KEWltMhs=|{xor}Aw0qMWltEjs=)"{0,1}$} }
  #   its('content') { should match %r{Require(\s"{0,1})ldap-group\sCN=WAS_ADMIN_eBiz,CN=Users,DC=ms,DC=ds,DC=uhc,DC=com"{0,1}$} }
  #
  #   if networkzone == 'intranet'
  #     its('content') { should match %r{AuthLDAPUrl(\s"{0,1})ldap:\/\/ad-ldap-prod.uhc.com:389\/CN=Users,dc=ms,dc=ds,dc=uhc,dc=com\?cn"{0,1}$} }
  #   elsif networkzone == 'internet'
  #     its('content') { should match %r{AuthLDAPUrl(\s"{0,1})ldap:\/\/ad-ldap-prod-dmzmgmt.uhc.com:636\/CN=Users,dc=ms,dc=ds,dc=uhc,dc=com\?cn"{0,1}$} }
  #   else
  #     raise 'Unsupported network zone.'
  #   end
  # end
end

control 'apache-config-files-4.0' do
  impact 1.0
  title '** test disabled conf.d files **'
  desc 'original ssl.cof, welcome.conf, userdir.conf(2.4 only) should be disabled in conf.d'

  describe file("/ebiz/apache/httpd/conf.d/ssl.conf") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.2'
    end
    it {  should_not exist }
  end

  describe file("/ebiz/apache/httpd/conf.d/welcome.conf") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.2'
    end
    it {  should_not exist }
  end

  describe file("/ebiz/apache/httpd/conf.d/userdir.conf") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.2'
    end
    it { should_not exist }
  end

  describe file("/ebiz/jws/httpd/conf.d/ssl.conf") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.4'
    end
    it {  should_not exist }
  end

  describe file("/ebiz/jws/httpd/conf.d/welcome.conf") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.4'
    end
    it {  should_not exist }
  end

end

control 'apache-config-files-5.0' do
  impact 1.0
  title '** test disabled conf.d files **'
  desc '00-mpm.conf, 00-base.conf and 00-proxy.conf are placed in conf.modules.d dir for 2.4.'
  describe file("/ebiz/apache/httpd/conf.modules.d/00-mpm.conf") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.2'
    end
    it {  should exist }
  end

  describe file("/ebiz/apache/httpd/conf.modules.d/00-base.conf") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.2'
    end
    it {  should exist }
    its('content') { should match %r{^DefaultRuntimeDir(\s"{0,1})\/ebiz\/apache\/httpd\/run"{0,1}$} }
  end

  describe file("/ebiz/apache/httpd/conf.modules.d/00-proxy.conf") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.2'
    end

    it { should exist }
  end
end

control 'apache-config-files-6.0' do
  impact 1.0
  title '** test html error files **'
  desc 'html error files 403.html, 404.html, 500.html should be placed in the html error dir'
  describe file("/ebiz/apache/httpd/www/html/error/403.html") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.2'
    end

    it { should exist }
    its('content') { should match 'Our web site is temporarily unavailable' }
  end

  describe file("/ebiz/apache/httpd/www/html/error/404.html") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.2'
    end

    it { should exist }
    its('content') { should match 'Sorry for the inconvenience.' }
  end

  describe file("/ebiz/apache/httpd/www/html/error/500.html") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.2'
    end

    it { should exist }
    its('content') { should match 'Please try again shortly.' }
  end

  # for 2.2
  describe file("/ebiz/jws/httpd/www/html/error/403.html") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.4'
    end

    it { should exist }
    its('content') { should match 'Our web site is temporarily unavailable' }
  end

  describe file("/ebiz/jws/httpd/www/html/error/404.html") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.4'
    end

    it { should exist }
    its('content') { should match %r{'Sorry for the inconvenience'} }
  end

  describe file("/ebiz/jws/httpd/www/html/error/500.html") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.4'
    end

    it { should exist }
    its('content') { should match %r{'Please try again shortly.'} }
  end

end

control 'apache-config-files-7.0' do
  impact 1.0
  title '** test apachectl is placed in the sbin dir **'
  desc 'apachectl is placed in the sbin dir'
  describe file("/ebiz/apache/httpd/sbin/apachectl") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.2'
    end
    it { should exist }
    its('content') { should match %r{^HTTPD=''{0,1}\/ebiz\/apache\/httpd\/sbin\/httpd'{0,1}$} }
    its('content') { should match %r{^export\sLD_LIBRARY_PATH="{0,1}\/ebiz\/apache\/httpd\/lib\:\$LD_LIBRARY_PATH"{0,1}$} }
  end

  # feng to do - check of need to add the binary and lib path to 2.2. It default to ./HTTPD
  # describe file("/ebiz/jws/httpd/sbin/apachectl") do
  #   let(:node) { json('/var/chef/kitchen/chef_node.json').params }
  #   let(:version) {node['default']['optum_apache']['version']}
  #   before do
  #     skip if version == '2.4'
  #   end
  #   it { should exist }
  #   its('content') { should match %r{^HTTPD="{0,1}\/ebiz\/jws\/httpd\/sbin\/httpd"{0,1}$} }
  #   its('content') { should match %r{^export\sLD_LIBRARY_PATH="{0,1}\/ebiz\/jws\/httpd\/lib\:\$LD_LIBRARY_PATH"{0,1}$} }
  # end
end
