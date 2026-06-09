#!/bin/sh

cd "$(dirname "$(realpath "$0")")"

if ! which ansible 1>/dev/null 2>&1; then
    echo "Ansible could not be found. Ensure the ansible binary is installed and in your path."
    exit 1
fi

if [ ! -f ./minecraft_hosts.ini ]; then
    echo "./minecraft_hosts.ini could not be found. You may need to run ./provision.sh again."
    exit 1
fi

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ./minecraft_hosts.ini ./configure.yml
