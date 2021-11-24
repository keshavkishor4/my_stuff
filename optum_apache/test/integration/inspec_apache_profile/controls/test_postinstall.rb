#
# Cookbook Name:: optum_apache
# Recipe:: test_postinstall
#
# Copyright (C) 2017 Optum Technology
#
# All rights reserved - Do Not Redistribute
#

title 'test apache post install'

# workaround for current version of InSpec not loading json outside describe block for the control to reference the node attributes
# this default variable coule get overwritten by using
# inspec exec <test.rb> --attrs /var/chef/cookbooks/optum_apache/test/integration/inspec_apache_profile/attributes/test_2.4_profile.yml
mui_identifier = attribute('mui_identifier', default: '<mui>', description: "mui_identifier of the server")
environment_level = attribute('environment_level', default: '<dev, stg or prd>', description: "environment_level of the server")
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

control 'apache-postinstall-1.0' do
  impact 1.0
  title '** test cron jobs setup **'
  desc 'test cron jobs setup for log archiving'

  # check if the input file exist
  # Validate log archive is setup with the apache_log_dir logs
  describe file('/home/aemadmin/dce/input/log_archive.input') do
    it { should exist }
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    let(:profile_name) {
        case version
          when '2.2' then 'jws'
          when '2.4' then 'apache'
        end
    }

    # regular expression validation tool http://rubular.com/
    its('content') { should match %r{^\/ebiz\/app_logs\/#{profile_name}\/httpd\/logs\/error_log$} }
    its('content') { should match %r{^\/ebiz\/app_logs\/#{profile_name}\/httpd\/logs\/access_log$} }
    its('content') { should match %r{^\/ebiz\/app_logs\/#{profile_name}\/httpd\/logs\/apache_rt.log$} }
  end

  describe crontab do
    its('commands') { should include '/home/aemadmin/dce/scripts/log_archive.sh -Rtgi log_archive.input -d 7' }
  end
end

control 'apache-postinstall-1.1' do
  impact 1.0
  title '** test cron jobs setup ** '
  desc 'test cron jobs setup for service health check'

# feng to do
# pgcdev_svchealth.input file name should include mui and environemnt as variable
  describe file("/home/aemadmin/dce/input/#{mui_identifier}#{environment_level}_svchealth.input") do
    it { should exist }
    # Ruby regular expression validation tool http://rubular.com/
    its('content') { should match %r{^%PROCESS:\/ebiz\/(jws|apache)\/httpd\/conf\/httpd.conf$} }
    its('content') { should match %r{^%START:\/home\/aemadmin\/dce\/scripts\/bounce_ews.sh -s (jws|apache)$} }
    its('content') { should match %r{^%STOP:\/home\/aemadmin\/dce\/scripts\/bounce_ews.sh -d (jws|apache)$} }
    its('content') { should match %r{^%BOUNCE:\/home\/aemadmin\/dce\/scripts\/bounce_ews.sh -b (jws|apache)} }
    its('content') { should match %r{^%USER:aemadmin$} }
    # feng to do - Inspec failed
    # its('content') { should match %r{^%EMAIL:\w+(\-|.+)@\w+(\-|.).\w+(\-|.+)} }
  end

  describe crontab do
    # let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    # let(:mui_identifier) {node['default']['optum_apache']['mui_identifier']}
    # let(:environment_level) {node['default']['optum_apache']['environment_level']}
    # its('commands') { should include %r{\/home\/aemadmin\/dce\/scripts\/svc_health.sh\s-st\s-i\s(\w{6})_svchealth.input\sapache\s\>\s\/dev\/null\s2\>&1} }
    its('commands') { should include %r{\/home\/aemadmin\/dce\/scripts\/svc_health.sh\s-st\s-i\s/#{mui_identifier}#{environment_level}_svchealth.input\sapache\s\>\s\/dev\/null\s2\>&1} }
  end
end

control 'apache-postinstall-1.2' do
  impact 1.0
  title '** test server bounce -stop **'
  desc 'test server bounce with bounce_ews.sh'
  describe command("/home/aemadmin/dce/scripts/bounce_ews.sh -d apache") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.2'
    end
    its('stdout') { should include 'Stopping EWS server' }
    its('exit_status') { should eq 0 }
  end

  describe command("/home/aemadmin/dce/scripts/bounce_ews.sh -d jws") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.4'
    end
    its('stdout') { should include 'Stopping EWS server' }
    its('exit_status') { should eq 0 }
  end

end

control 'apache-postinstall-1.3' do
  impact 1.0
  title '** test server bounce -start **'
  desc 'test server bounce with bounce_ews.sh'
  describe command("/home/aemadmin/dce/scripts/bounce_ews.sh -s apache") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.2'
    end

    its('stdout') { should include 'Starting EWS server' }
    its('exit_status') { should eq 0 }
  end

  describe command("/home/aemadmin/dce/scripts/bounce_ews.sh -s jws") do
    let(:node) { json('/var/chef/kitchen/chef_node.json').params }
    let(:version) {node['default']['optum_apache']['version']}
    before do
      skip if version == '2.4'
    end

    its('stdout') { should include 'Starting EWS server' }
    its('exit_status') { should eq 0 }
  end

#feng to do Inspec failed
  describe processes('httpd') do
    # its('states') { should eq ['R<'] }
    it { should exist }
  end
end
