# MongoDB Enterprise and Ops Manager Setup

This project contains Ansible playbooks and scripts for setting up a MongoDB Enterprise replica set, deploying MongoDB Ops Manager, and setting up a nginx load balancer for Ops Manager.

## Directory Structure

```
mongodb/
├── README.md (this file)
├── enterprise/ansible
│   ├── mongodb_enterprise_replica_set_setup.yml
│   ├── mongod_no_auth.conf.j2
│   ├── mongod_auth.conf.j2
│   ├── disable_thp.yml
│   └── setup.sh
└── ops_mgr/ansible
    ├── deploy_ops_manager.yml
    ├── conf-mms.properties.j2
    ├── setup_nginx_load_balancer.yml
    └── nginx.conf.j2
```

## Files and Their Purposes

### Enterprise Setup (`enterprise/` directory)

1. `mongodb_enterprise_replica_set_setup.yml`
   - Main Ansible playbook for setting up MongoDB Enterprise replica set
   - Installs MongoDB Enterprise
   - Configures replica set
   - Sets up authentication

2. `mongod_no_auth.conf.j2` and `mongod_auth.conf.j2`
   - Jinja2 templates for MongoDB configuration files
   - Used during the initial setup and after enabling authentication

3. `disable_thp.yml`
   - Ansible playbook for disabling Transparent Huge Pages (THP)

4. `setup.sh`
   - Bash script that orchestrates the enterprise setup process

### Ops Manager Setup (`ops_mgr/` directory)

1. `deploy_ops_manager.yml`
   - Ansible playbook for deploying MongoDB Ops Manager across two VMs
   - Installs dependencies
   - Downloads and installs Ops Manager
   - Configures Ops Manager to use an existing MongoDB replica set as its application database

2. `conf-mms.properties.j2`
   - Jinja2 template for Ops Manager configuration file

3. `setup_nginx_load_balancer.yml`
   - Ansible playbook for setting up nginx as a load balancer for Ops Manager
   - Installs and configures nginx

4. `nginx.conf.j2`
   - Jinja2 template for nginx configuration

## Usage

### Enterprise Setup

1. Navigate to the `mongodb/enterprise` directory:
   ```
   cd mongodb/enterprise/ansible
   ```

2. Update the `hosts` inventory file with the IP addresses of your MongoDB servers.

3. Run the setup script:
   ```
   ./setup.sh
   ```

   Or run the playbooks manually:
   ```
   ansible-playbook -i hosts disable_thp.yml --ask-become-pass
   ansible-playbook -i hosts mongodb_enterprise_replica_set_setup.yml --ask-become-pass
   ```

### Ops Manager Deployment

1. Navigate to the `mongodb/ops_mgr` directory:
   ```
   cd mongodb/ops_mgr/ansible
   ```

2. Ensure you have set up the application database replica set using the enterprise setup playbook.

3. Update the Ops Manager config that's inline in the playbook with the correct application database URI and other settings.

4. Run the Ops Manager deployment playbook:
   ```
   ansible-playbook -i hosts deploy_ops_manager.yml --ask-become-pass
   ```

### Nginx Load Balancer Setup

1. In the `mongodb/ops_mgr/bash` directory, run the nginx setup script:
   ```
   deploy_nginx_loadbalancer.sh
   ```

## Notes

- Ensure that the application database replica set is properly set up and accessible from the Ops Manager servers.
- The nginx load balancer should be configured with appropriate SSL/TLS settings for production use.
- Always test these playbooks in a non-production environment before applying them to production systems.
- Regularly update passwords and security settings in production environments.

## Troubleshooting

If you encounter issues:

1. Check the Ansible output for specific error messages.
2. Verify network connectivity between all components.
3. Ensure all required ports are open.
4. Check MongoDB and Ops Manager log files on the servers for any error messages.

For MongoDB:
```
sudo tail -f /var/log/mongodb/mongod.log
```

For Ops Manager:
```
sudo tail -f /opt/mongodb/mms/logs/mms.log
```
