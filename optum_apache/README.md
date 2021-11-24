# optum_apache

This cookbook is to install and configure Red Hat JBoss Apache HTTP Server version 2.2 or version 2.4 on RHEL7.

### Requirements
- Chef-client 12.18 or above
- git
  - git --version
  - yum install -y wget curl git

### Platform Support
- RHEL7

### The cookbook assumes that the following steps complete before run the cookbook on the node.
- optum_middleware_setup
- lvm
- APS pushfiles, including
  - PaaS-Utilities/optum_aps_scripts and
  - PaaS-Utilities/optum_rhel_scripts

### Steps to run the cookbook in chef local mode (-z or --local-mode option) using custom attributes

- Check if chef-client is installed on the node
    - chef-client -version
- Check if git is installed on the node.
    - rpm -q git
    - yum install git
- Create directories for the cookbook
      - mkdir -p /var/chef/cookbooks (or /opt/chef-repo/cookbooks)
- Get cookbooks from GitHub
    - sudo git clone https://github.optum.com/PaaS-Cookbooks/optum_apache
    - Notes: The middleware and lvm cookbook will be called from vRo once the workflow is ready. Apache cookbook doesn't directly include the middleware and lvm in the berksfile.
    - sudo git clone https://github.optum.com/PaaS-Cookbooks/optum_middleware_setup.git
    - sudo git clone https://github.optum.com/PaaS-Common/optum_lvm.git
- Run cookbook
    - Update the Apache version, mui, environment level and network zone in recipes/default.rb test data session
    - Artifactory credentials are required to pull the binaries. It is a security concern to use the unencrypted password in the attribute file.
    - sudo chef-client -z -o optum_apache
- Start/Stop Apache server
    - Apache 2.4 server name = apache
    - Apache 2.2 server name = jws
    - START:/home/aemadmin/dce/scripts/bounce_ews.sh -s <server name>
    - STOP:/home/aemadmin/dce/scripts/bounce_ews.sh -d <server name>
    - BOUNCE:/home/aemadmin/dce/scripts/bounce_ews.sh -b <server name>

- Check running version
    - /ebiz/<apache or jws>/httpd/sbin/httpd -v

### Steps to run the cookbook in chef local mode with data_bags and data_bags_secrets
- Assume that the chef-repo is configured to run the chef-client at /opt/chef-repo
- Create the data_bags/apache directories
- Create file apache_setup.json.
- For example,
  {
    "id": "apache_setup",
    "mui_identifier": "ATE",
    "version": "2.4",
    "environment_level": "DEV",
    "networkzone": "intranet"
  }
- Create artifactory_user.json and artifactory_password.json in data_bags/artifactory directory
- artifactory_user.json example
  {
    "id": "artifactory_user",
    "artif_user": "myUserName"
  }
- artifactory_password.json example
  {
   "id": "artifactory_password",
   "artif_password": {
     "encrypted_data": "myEncryptedPassword",
     "iv": "mySecretKey",
     "version": 1,
     "cipher": "aes-256-cbc"
   }
  }
- cd /opt/chef-repo/cookbooks
- sudo chef-client -c /etc/chef/client_local.rb -o recipe[optum_apache::default]

### CI/CD and Hardening Tasks    

- Integration testing with InSpec (under development)
    - [X] Create test profile inspec.yml and run the test on the node.
    - [X] Write test cases
    - [X] Validate the tests for apache 2.4
    - [P] Validate the tests for apache 2.2
    - [X] Workaround for accessing node attributes in the controls. Right now combine the testing attribute with node attribute export file. Waiting for better soluion from Chef/InSpec
- Testing with test kitchen (under development)
    - [X] Request VM Workstation Pro 12.5.5. Ariba issued the license for v.14. Waiting for v14 to be posted in appstore.
    - [P] Build PaaS iso image for linux 7
    - [P] Set up test kitchen
- Automated integration testing approach
    - Local
      - inspec exec --log-location <log_dir> <test.rb or profile> --attrs <test_2.4_profile.yml> or <test_2.2_profile.yml>
      - e.g. sudo inspec exec inspec_apache_profile --attrs ./inspec_apache_profile/attributes/test_2.4_profile.yml
    - Remote e.g. inspec exec tester.rb -t ssh://admintest@X.X.X.X --password 'test' --sudo-password=test --sudo
    - Kitchen
      - Create test VM e.g. kitchen create test_vm_platform_version
      - Pull dependencies and run recipes e.g. kitchen converge test_vm_platform_version
      - Run test e.g. kitchen verify test_vm_platform_version
      - Clean up kitchen e.g. kitchen destroy test_vm_platform_version
      - Kitchen test e.g. kitchen test test_vm_platform_version
- Prerequisite
  - git
  - ruby
  - InSpec (included in ChefDK) - The easy way to set up the environment to run InSpec is to install ChefDK.
    - wget https://packages.chef.io/files/stable/chefdk/<version>/<platform>/<rpm>
    - rpm -ivh chefdk-<version>.<platform>.rpm
- vRa/vRo integration
- Jenkins pipeline
