#!/bin/bash

set -e

# Configuration variables
OPS_MANAGER_PACKAGE="mongodb-mms-7.0.8.500.20240627T1700Z.amd64.deb"
APP_DB_URI="mongodb://mongoAdmin:NewPassword123@34.87.173.21,34.126.175.212,35.247.142.158/?replicaSet=rs0&authSource=admin"
EXTERNAL_IP="34.126.175.212"

# Function to check if script is run as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "This script must be run as root" 1>&2
        exit 1
    fi
}

# Function to install dependencies
install_dependencies() {
    apt-get update
    apt-get install -y libcurl4 liblzma5 curl
}

# Function to install Ops Manager
install_ops_manager() {
    if [ ! -f "$OPS_MANAGER_PACKAGE" ]; then
        echo "Ops Manager package not found at $OPS_MANAGER_PACKAGE" 1>&2
        exit 1
    fi
    dpkg -i "$OPS_MANAGER_PACKAGE"
    apt-get install -f  # Install any missing dependencies
}

# Function to create Ops Manager configuration
create_config() {
    cat > /opt/mongodb/mms/conf/conf-mms.properties << EOF
# Ops Manager Configuration File

# Ops Manager Application URL
mms.centralUrl=http://${EXTERNAL_IP}:8080

# MongoDB Application Database
mongo.mongoUri=$APP_DB_URI

# HTTPS Configuration (currently not in use)
mms.https.ClientCertificateMode=OPTIONAL

# Email Configuration (currently not in use)
mms.fromEmailAddr=noreply@example.com
mms.replyToEmailAddr=reply@example.com
mms.adminEmailAddr=admin@example.com
mms.mail.transport=smtp
mms.mail.hostname=smtp.example.com
mms.mail.port=587

# General Configuration
mms.ignoreInitialUiSetup=true

# Logging Configuration
mms.logger.level=INFO
EOF

    chown mongodb-mms:mongodb-mms /opt/mongodb/mms/conf/conf-mms.properties
    chmod 600 /opt/mongodb/mms/conf/conf-mms.properties
}

# Function to start Ops Manager service
start_ops_manager() {
    systemctl enable mongodb-mms
    systemctl restart mongodb-mms
}

# Function to wait for Ops Manager to start
wait_for_ops_manager() {
    echo "Waiting for Ops Manager to start..."
    for i in {1..30}; do
        if curl -s http://${EXTERNAL_IP}:8080 > /dev/null; then
            echo "Ops Manager is up and running!"
            echo "You can access it at: http://${EXTERNAL_IP}:8080"
            return 0
        fi
        sleep 10
    done
    echo "Ops Manager did not start within the expected time." 1>&2
    return 1
}

# Main execution
main() {
    check_root
    install_dependencies
    install_ops_manager
    create_config
    start_ops_manager
    wait_for_ops_manager
}

# Run the script
main