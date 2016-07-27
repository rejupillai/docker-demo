
@REM - Removes all the dockerhosts before creating new nodes
docker-machine rm dockerhost-keystore dockerhost-swarm-master dockerhost-registry dockerhost-rundeck dockerhost-worker --force

@REM - Create a node for Keystore to be used by Consul  
docker-machine create -d virtualbox dockerhost-keystore
docker-machine env dockerhost-keystore
@FOR /f "tokens=*" %i IN ('docker-machine env dockerhost-keystore') DO @%i
docker run -d -p "8500:8500" -h "consul" progrium/consul -server -bootstrap

@REM - Get the generated IP-Addr for the Consul's Keystore
SET dockerhost-keystore-ip-cmd="docker-machine ip dockerhost-keystore"
@FOR /F %i IN ( '%dockerhost-keystore-ip-cmd%' ) DO  SET   dockerhost-keystore-ip=%i

@REM - Create a Swarm master node pointing to the the Consul address
docker-machine create -d virtualbox  --virtualbox-memory "2048" --swarm --swarm-master --swarm-discovery="consul://%dockerhost-keystore-ip%:8500" --engine-label nodename=dh-swarm-master --engine-opt="cluster-store=consul://%dockerhost-keystore-ip%:8500" --engine-opt="cluster-advertise=eth1:2376" dockerhost-swarm-master

@REM - Create a Swarm worker node for Docker local Registry to store images within the Firewall of the organizations
docker-machine create -d virtualbox --virtualbox-memory "2024" --swarm --swarm-discovery="consul://%dockerhost-keystore-ip%:8500" --engine-label nodename=dh-registry  --engine-insecure-registry "localhost:5000" --engine-registry-mirror "http://localhost:5000" --engine-opt="cluster-store=consul://%dockerhost-keystore-ip%:8500" --engine-opt="cluster-advertise=eth1:2376" dockerhost-registry

@REM - Create a worker node for rundeck for runbook automation
docker-machine create -d virtualbox --virtualbox-memory "2048" --swarm --swarm-discovery="consul://%dockerhost-keystore-ip%:8500" --engine-label nodename=dh-rundeck   --engine-opt="cluster-store=consul://%dockerhost-keystore-ip%:8500" --engine-opt="cluster-advertise=eth1:2376" dockerhost-rundeck

@REM - Create a Swarm worker node for hosting Applications 
docker-machine create -d virtualbox --virtualbox-memory "3072" --swarm --swarm-discovery="consul://%dockerhost-keystore-ip%:8500" --engine-label nodename=dh-worker --engine-opt="cluster-store=consul://%dockerhost-keystore-ip%:8500" --engine-opt="cluster-advertise=eth1:2376" dockerhost-worker

@REM - Create a Swarm worker node for hosting Applications 
@REM docker-machine create -d virtualbox --virtualbox-memory "2048" --swarm --swarm-discovery="consul://%dockerhost-keystore-ip%:8500" --engine-label="nodename=dh-ci" --engine-opt="cluster-store=consul://%dockerhost-keystore-ip%:8500" --engine-opt="cluster-advertise=eth1:2376" dockerhost-ci

@REM - Create an overlay network for multi-host communication using 'overlay' driver
docker-machine env --swarm dockerhost-swarm-master
@FOR /f "tokens=*" %i IN ('docker-machine env --swarm dockerhost-swarm-master') DO @%i

@REM - Lsit all the nodes
docker-machine ls

@REM - List all networks
docker network ls

@REM ----------------------------

@REM - Removes all the containers before creating new nodes
docker rm compose_worker_1  registry registry-data-container rundeck-data-container rundeck worker-data-container --force

@REM - Docker Compose up - build from Dockerfile and spin up containers, networks, storage etc



docker-compose -f compose/docker-compose.yml  stop storage-registry  storage-rundeck  storage-worker storage-gitlab
docker-compose -f compose/docker-compose.yml  stop registry  rundeck  worker gitlab
docker-compose -f compose/docker-compose.yml  rm -f
docker-compose -f compose/docker-compose.yml  up -d 


@REM ----------------------------


@REM Rundeck initial setup
@REM - Create a worker_node for rundeck
docker-machine env dockerhost-worker
@FOR /f "tokens=*" %i IN ('docker-machine env dockerhost-worker') DO @%i
docker-machine scp -r rundeck  dockerhost-worker:/tmp
docker exec worker_1 apt-get --assume-yes  install  dos2unix
docker exec worker_1 dos2unix /tmp/rundeck/setup_passwdless_ssh.sh  /tmp/rundeck/setup_passwdless_ssh.sh 
docker exec worker_1 sh /tmp/rundeck/setup_passwdless_ssh.sh
docker-machine ssh dockerhost-rundeck mkdir /tmp/private-ssh-keys/
docker-machine scp dockerhost-worker:/tmp/id_rsa  dockerhost-rundeck:/tmp/private-ssh-keys/worker_1.key
docker-machine scp rundeck/resources.xml dockerhost-rundeck:/tmp/

@REM - Create a worker_node for rundeck -- ends 

@REM  docker-compose scale worker_1 3

@REM - Check the consul UI  at :  http://localhost:8500/ui/#/dc1/kv/docker/nodes/

@REM - Create few nodes for rundeck using run commands	

@REM -  A Container can be connected over multiple networks ; in this it's connected to both   compose_overlay-net  {10.} - for C 2 C  communication ; and  bridge {172.} to connect from HOST to C 

@REM docker network connect bridge <CID>

@REM dockerhost-rundeck:~$ docker exec -i -t  rd-node-2  /bin/bash

@REM  PASS=root

@REM echo -e "$PASS\n$PASS" | docker exec -i rd-node-1 passwd

@REM $ docker volume rm $(docker volume ls -qf dangling=true)











