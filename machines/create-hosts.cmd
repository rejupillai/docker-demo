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
docker-machine create -d virtualbox --swarm --swarm-master --swarm-discovery="consul://%dockerhost-keystore-ip%:8500" --engine-label nodename=dh-swarm-master --engine-opt="cluster-store=consul://%dockerhost-keystore-ip%:8500" --engine-opt="cluster-advertise=eth1:2376" dockerhost-swarm-master

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

@REM - Docker Compose up - build from Dockerfile and spin up containers, networks, storage etc
docker-compose -f compose/docker-compose.yml  up -d 

@REM - Check the consul UI  at :  http://localhost:8500/ui/#/dc1/kv/docker/nodes/
@REM - Create few nodes for rundeck using run commands	
@REM -  A Container can be connected over multiple networks ; in this it's connected to both   compose_overlay-net  {10.} - for C 2 C  communication ; and  bridge {172.} to connect from HOST to C 
@REM docker network connect bridge <CID>
@REM dockerhost-rundeck:~$ docker exec -i -t  rd-node-2  /bin/bash
@REM  PASS=root
@REM echo -e "$PASS\n$PASS" | docker exec -i rd-node-1 passwd









