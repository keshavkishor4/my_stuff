#
# Cookbook Name:: optum_apache
# Recipe:: pre_install
#
# Copyright (C) 2017 Optum Technology
#
# All rights reserved - Do Not Redistribute
#

# Package resource named openssl with install action
package 'openssl' do
  action :install
end

# Package resource named ldap with install action
package 'openldap' do
  action :install
end

# Package resource named apr with install action
package 'apr' do
  action :install
end

# Package resource named gdb with install action
package 'gdb' do
  action :install
end

# Package resource named apr-util with install action
package 'apr-util' do
  action :install
end

# Package resource named apr-util-ldap with install action
package 'apr-util-ldap' do
  action :install
end

# Package resource named mailcap with install action.
# Otherwise, apachectl gives error "AH01597: could not open mime types config file" when satrt httpd.
package 'mailcap' do
  action :install
end
