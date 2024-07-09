#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook -i hosts disable_thp.yml --ask-become-pass
ansible-playbook -i hosts mongodb_enterprise_replica_set_setup.yml --ask-become-pass

echo "Replica set setup successfully."

mongorestore --uri="mongodb://mongoAdmin:Password123@192.168.64.5:27017,192.168.64.6:27017,192.168.64.7:27017/?replicaSet=rs0" --dir=dump

echo "Data loaded successfully."