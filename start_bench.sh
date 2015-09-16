#!/bin/bash

if [ -z "$1" ]
  then
    echo "usage: $0 <vars.json>"
    echo ""
    echo " vars.json - json file containing custom benchmark options"
    echo "             please see example-bb.json"
    exit
fi

cleanup () {
  ansible-playbook plays/w01_rm_instances.yml
  ansible-playbook plays/w02_rm_vpc.yml
  rm -r -f inventory
  exit
}

if [ ! -d inventory ]; then
  mkdir inventory
  echo "[local]" >> inventory/hosts
  echo "localhost" >> inventory/hosts
  ansible-playbook plays/00_init_set.yml --extra-vars "@$1"
  cp plays/files/ec2.py inventory/
  ansible-playbook plays/01_mk_vpc.yml --extra-vars "@$1"
else
  echo "Inventory Directory found, not creating new VPC"
  echo "Please run wipe.sh to clean up hosts+vpc"
  echo "and remove inventory dir to start a new benchmark"
fi

if [ $? -eq 1 ]; then cleanup; fi
ansible-playbook plays/02_start_instances.yml
if [ $? -eq 1 ]; then cleanup; fi
./inventory/ec2.py --refresh-cache > /dev/null
ansible-playbook plays/03_tag_master.yml
if [ $? -eq 1 ]; then cleanup; fi
ansible-playbook plays/04_add_volumes.yml
if [ $? -eq 1 ]; then cleanup; fi
./inventory/ec2.py --refresh-cache > /dev/null
ansible-playbook plays/05.pre_upgrade_kernel.yml
if [ $? -eq 1 ]; then cleanup; fi
# ansible-playbook plays/05.pre_tune.yml
# if [ $? -eq 1 ]; then cleanup; fi
ansible-playbook plays/05_setup_riak.yml
if [ $? -eq 1 ]; then cleanup; fi
ansible-playbook plays/06_setup_metrics.yml
if [ $? -eq 1 ]; then cleanup; fi
ansible-playbook plays/07_setup_bb.yml
if [ $? -eq 1 ]; then cleanup; fi
ansible-playbook plays/08_start_bb.yml
ansible-playbook plays/09_gather_results.yml
if [ $? -eq 1 ]; then cleanup; fi

# cleanup
