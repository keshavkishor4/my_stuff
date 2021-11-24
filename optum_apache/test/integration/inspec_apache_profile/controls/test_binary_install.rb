#
# Cookbook Name:: optum_apache
# Recipe:: test_binary_install
#
# Copyright (C) 2017 Optum Technology
#
# All rights reserved - Do Not Redistribute
#
require 'json'

title 'test apache binary install'
profile_name = attribute('profile_name', default: '<apache or jws>', description: "profile_name of apache")

control 'apache-pre-0.0' do
  impact 1.0
  title '** Prerequisite:  Node attribute export file should exist to provide the test data **'
  desc ' Node atrribute export file exist to provide the test data.'
  describe file('/var/chef/kitchen/chef_node.json') do
    it { should exist }
    its('mode') { should cmp '00755' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
  end
end

control 'apache-pre-1.0' do
  impact 1.0
  title '** test aemadmin and dce **'
  desc 'check if the aemadmin:dce exist'
  describe user('aemadmin') do
    it { should exist }
    its('group') { should eq 'dce' }
  end
end

control 'apache-pre-2.0' do
  impact 1.0
  title '** test aemadmin pushfile **'
  desc 'pushfile should laydown the aemadmin scripts. Apache cookbook assumes that the aemadmin is setup.'
  describe file('/home/aemadmin/dce/scripts') do
    it { should exist }
    its('mode') { should cmp '00750' }
    its('owner') { should eq 'aemadmin' }
    its('group') { should eq 'dce' }
  end
end

# feng to do -- check the Prerequisites

control 'apache-install-1.0' do
  impact 1.0
  title '** test apache home symbolic link is create. e.g /ebiz/apache/ **'
  desc 'apache home points to apache or jws version install dir'
  describe file('/ebiz/apache') do

    before do
      skip unless ::File.exist?('/var/chef/kitchen/chef_node.json')
   end

    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) { node['default']['optum_apache']['version'] }

    before do
      skip if version == '2.2'
    end

    # it's a duplicate just for observing inSpec symlink check
    its('type') { should eq 'symlink' }
    it { should be_linked_to '/ebiz/install/jbcs-httpd24-2.4' }
    it { should_not be_file }
    it { should_not be_directory }
  end

  describe file('/ebiz/jws') do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) { node['default']['optum_apache']['version'] }
    before do
      skip if version == '2.4'
    end
    # it's a duplicate just for observing inSpec symlink check
    its('type') { should eq 'symlink' }
    it { should be_symlink }
    it { should be_linked_to '/ebiz/install/jboss-ews-2.1' }
    it { should_not be_file }
    it { should_not be_directory }
  end
end

control 'apache-install-1.1' do
  impact 1.0
  title '** test serverroot is created. e.g /ebiz/<apache or jws>/httpd ** '
  desc 'serverroot points to httpd under apache or jws version install dir '
  describe file('/ebiz/apache/httpd') do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) { node['default']['optum_apache']['version'] }
    before do
      skip if version == '2.2'
    end
    it { should exist }
    its('mode') { should cmp '00750' }
    its('owner') { should eq 'aemadmin' }
    its('group') { should eq 'dce' }
  end

  describe file('/ebiz/jws/httpd') do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) { node['default']['optum_apache']['version'] }
    before do
      skip if version == '2.4'
    end
    it { should exist }
    its('mode') { should cmp '00750' }
    its('owner') { should eq 'aemadmin' }
    its('group') { should eq 'dce' }
  end
end

# feng to do - evaluate a better way to test two apache/jws versions. It will will be best if all the test data come from node itself instead of test attributes
# 1) read the version or attributes from the node attribute export
# 2) provide the test data in the attribute file
control 'apache-install-2.0' do
  impact 1.0
  title '** test permission of /ebiz/<apache or jws>/httpd ** '
  desc 'test permission of /ebiz/<apache or jws>/httpd'

  apache_files = command("ls -d /ebiz/#{profile_name}/httpd/*").stdout.split("\n")

  apache_files.each { |apache_file|
    describe file(apache_file) do
      its('mode') { should cmp '00750' }
      its('owner') { should eq 'aemadmin' }
      its('group') { should eq 'dce' }
    end
  }
end
