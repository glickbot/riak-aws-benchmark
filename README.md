### Riak AWS Benchmarking

#### About

The idea is to be able to specify size/type of Riak cluster, and size/type of benchmark, and this will automatically spin up AWS instances, benchmark, record info, save all the results, and then blow away all nodes.

#### Features
* creates a VPC
* attaches/formats/configures volumes of custom type
* tunes instances
* uses influxdb and configures telegraf on all nodes
* imports all riak stats using telegraf
* uses distributed basho_bench & generates summary
* copies influxdb dataset & benchmark results locally
* wipes everything after benchmark

#### Usage
* set your boto/AWS creds:
	* [http://docs.ansible.com/ansible/ec2_module.html](http://docs.ansible.com/ansible/ec2_module.html) )
* copy and edit ```example-bb.json``` options

* run ```./start_bench.sh```

###### NOTE: 
* by default, start_bench.sh will also wipe the cluster once it's done

###### TODO:

* test local influxdb data recovery
* add option to request spot instances
* create influxdb/grafana docker to view influxdb data
* option to use local/persistant influxdb