

@REM - Removes all the dockerhosts before creating new nodes

docker-machine rm dockerhost-keystore dockerhost-swarm-master  dockerhost-registry dockerhost-application dockerhost-ci --force


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
docker-machine create -d virtualbox --virtualbox-memory "1024" --swarm --swarm-discovery="consul://%dockerhost-keystore-ip%:8500" --engine-label nodename=dh-registry  --engine-insecure-registry localregistry:5000 --engine-opt="cluster-store=consul://%dockerhost-keystore-ip%:8500" --engine-opt="cluster-advertise=eth1:2376" dockerhost-registry

@REM - Create a Swarm worker node for hosting Applications 
@REM docker-machine create -d virtualbox --virtualbox-memory "3072" --swarm --swarm-discovery="consul://%dockerhost-keystore-ip%:8500" --engine-label="nodename=dh-application" --engine-opt="cluster-store=consul://%dockerhost-keystore-ip%:8500" --engine-opt="cluster-advertise=eth1:2376" dockerhost-application

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


