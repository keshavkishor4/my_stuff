#
# Cookbook Name:: optum_apache
# Recipe:: test_configuration
#
# Copyright (C) 2017 Optum Technology
#
# All rights reserved - Do Not Redistribute
#
require 'json'

title 'test apache configuration'

# workaround for current version of InSpec not loading json outside describe block for the control to reference the node attributes
# this default variable coule get overwritten by using
# inspec exec <test.rb> --attrs /var/chef/cookbooks/optum_apache/test/integration/inspec_apache_profile/attributes/test_2.4_profile.yml
host_fqdn = attribute('host_fqdn', default: '<hostname>.uhc.com', description: "the node/host fqdn")
# end of the workaround

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

# feng to do - command resource not stable. Need to spin off for 2.2 and 2.4
control 'apache-config-1.0' do
  impact 1.0
  title '** test .profile_apache or .profile_jws using getenv**'
  desc 'apache or jws profile is created.'
  describe command('getenv apache') do

    before do
      skip unless ::File.exist?('/var/chef/kitchen/chef_node.json')
    end

    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    # FC039 recommand using let(:version) {node.default['optum_apache']['version']}
    let(:profile_name) {
        case version
          when '2.2' then 'jws'
          when '2.4' then 'apache'
        end
    }

    before do
      skip if version == '2.2'
    end

    its('stdout') { should include profile_name.to_s }
    its('exit_status') { should eq 0 }
    its('stderr') { should eq '' }
  end

  describe command('getenv jws') do

    before do
      skip unless ::File.exist?('/var/chef/kitchen/chef_node.json')
    end

    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    # FC039 recommand using let(:version) {node.default['optum_apache']['version']}
    let(:profile_name) {
        case version
          when '2.2' then 'jws'
          when '2.4' then 'apache'
        end
    }

    before do
      skip if version == '2.4'
    end

    its('stdout') { should include profile_name.to_s }
    its('exit_status') { should eq 0 }
    its('stderr') { should eq '' }
  end

end

control 'apache-config-2.0' do
  impact 1.0
  title '** test httpd.conf syntax using apachectl **'
  desc 'test httpd.conf syntax using apachectl'
  # describe command("/ebiz/apache/httpd/sbin/apachectl -t -f /ebiz/apache/httpd/conf/httpd.conf") do
  describe command("/ebiz/apache/httpd/sbin/apachectl -t -f /ebiz/apache/httpd/conf/httpd.conf") do
    before do
      skip unless ::File.exist?('/var/chef/kitchen/chef_node.json')
    end
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.2'
    end

    its('stdout') { should match 'Syntax OK' }
    its('exit_status') { should eq 0 }
  end

  describe command("/ebiz/jws/httpd/sbin/apachectl -t -f /ebiz/jws/httpd/conf/httpd.conf") do
    before do
      skip unless ::File.exist?('/var/chef/kitchen/chef_node.json')
    end
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.4'
    end

    its('stdout') { should match 'Syntax OK' }
  end
end

control 'apache-config-3.0' do
  impact 1.0
  title '** test ews_status using http resource**'
  desc 'test ews_status using http resource'
  # current version of InSpec couldn't load json outside describe block,
  # using the default attribute as the workaround
  # node = json('/var/chef/kitchen/chef_node.json').params
  # host_fqdn = node['default']['optum_apache']['host_fqdn']
  describe http("http://#{host_fqdn}:1080/ews-status/", enable_remote_worker: true) do
      its('status') { should cmp '401' }
  end
end

control 'apache-config-3.1' do
  impact 1.0
  title '** test mod_cluster-manager using http resource**'
  desc 'test mod_cluster-manager using http resource'
  # let(:node) { json('/var/chef/kitchen/chef_node.json').params }
  # let(:host_fqdn) {node['default']['optum_apache']['host_fqdn']}
  # describe command("curl webrd1225.uhc.com:6666/mod_cluster-manager") do
  describe http("http://#{host_fqdn}:6666/mod_cluster-manager/", enable_remote_worker: true) do
    its('status') { should cmp '401' }
  end
end

# describe http('url', auth: {user: 'user', pass: 'test'}, params: {params}, method: 'method', headers: {headers}, data: data, open_timeout: 60, read_timeout: 60, ssl_verify: true) do
# feng to do - how do we handle the credentials for the testing, databag?
control 'apache-config-3.2' do
  impact 1.0
  title '** test ews-status with authentication using http resource, pending for the credentials **'
  desc 'test ews-status with authentication using http resource, pending for the credentials'
  # feng to do - remove reference to node attributes
  # let(:node) { json('/var/chef/kitchen/chef_node.json').params }
  # let(:host_fqdn) {node['default']['optum_apache']['host_fqdn']}
  # describe command("curl -u eaptestrtid2:password http://webrd1225.uhc.com:1080/ew-status/") do
  # describe http('url', auth: {user: 'user', pass: 'test'}, params: {params}, method: 'method', headers: {headers}, data: data, open_timeout: 60, read_timeout: 60, ssl_verify: true) do
  describe http("http://#{host_fqdn}:1080/ews-status/", auth: {user:'eaptestrtid2', pass: 'password'}, enable_remote_worker: true) do
    its('status') { should cmp '200' }
  end
end

control 'apache-config-3.0-alternative' do
  impact 1.0
  title '** test ews_status using curl **'
  desc 'test ews_status using curl'
  # let(:node) { json('/var/chef/kitchen/chef_node.json').params }
  # let(:host_fqdn) {node['default']['optum_apache']['host_fqdn']}
  # https://github.com/chef/inspec/issues/664
  # Current version of inspec doesn't support variables in controls
  # describe command("curl http://webrd1225.uhc.com:1080/ew-status/") do
  describe command("curl http://#{host_fqdn}:1080/ews-status/") do
    its('stdout') { should include '401' }
  end
end

control 'apache-config-3.1-alternative' do
  impact 1.0
  title '** test mod_cluster-manager using curl **'
  desc 'test mod_cluster-manager using curl'
  # let(:node) { json('/var/chef/kitchen/chef_node.json').params }
  # let(:host_fqdn) {node['default']['optum_apache']['host_fqdn']}
  # describe command("curl webrd1225.uhc.com:6666/mod_cluster-manager") do
  describe command("curl http://#{host_fqdn}:6666/mod_cluster-manager/") do
    its('stdout') { should include '401' }
  end
end

# feng to do - how do we handle the credentials for the testing, databag?
control 'apache-config-3.2-alternative' do
  impact 1.0
  title '** test ews_status-status with authentication using curl, pending for the credentials **'
  desc 'test ews-status with authentication using curl, pending for the credentials'
  # feng to do - remove reference to node attributes
  # let(:node) { json('/var/chef/kitchen/chef_node.json').params }
  # let(:host_fqdn) {node['default']['optum_apache']['host_fqdn']}
  # describe command("curl -u eaptestrtid2:password http://webrd1225.uhc.com:1080/ew-status/") do
  describe command("curl -u eaptestrtid2:password http://#{host_fqdn}:1080/ews-status/") do
    its('stdout') { should include '200' }
  end
end
