#!/bin/bash

export base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$1" ]
  then
    echo "usage: $0 <vars.json>"
    echo ""
    echo " vars.json - json file containing custom benchmark options"
    echo "             please see example-bb.json"
    exit
fi

config_json=$1

if [ -f init.sh ]; then
   source init.sh
fi

run () {
  echo "## RUNNING $@ ##"
  ansible-playbook $@ --extra-vars "@$config_json"
  if [ $? -gt 0 ]; then
    echo "##########################################"
    echo "# Playbook $0 failed, initiating cleanup #"
    echo "##########################################"
    cleanup
  fi
}

cleanup () {
  ansible-playbook plays/99_wipe.yml
  exit
}

if [ ! -d inventory ]; then
  mkdir inventory
  echo "[local]" >> inventory/hosts
  echo "localhost" >> inventory/hosts
  run plays/00_init_set.yml
  cp plays/files/ec2.py inventory/
  run plays/01_mk_vpc.yml
else
  echo "Inventory Directory found, not creating new VPC"
  echo "Please run wipe.sh to clean up hosts+vpc"
  echo "and remove inventory dir to start a new benchmark"
fi

#### Provision
run plays/02_start_instances.yml
./inventory/ec2.py --refresh-cache > /dev/null

run plays/03_tag_master.yml
run plays/04_add_volumes.yml
./inventory/ec2.py --refresh-cache > /dev/null

#### Setup
run plays/05_setup.yml

#### Bench
run plays/06_bench.yml
# cleanup
