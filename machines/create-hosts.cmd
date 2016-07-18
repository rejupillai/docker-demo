@REM - Create a node for Keystore to be used by Consul  
docker-machine create -d virtualbox DOCKERHOST-KEYSTORE
docker-machine env DOCKERHOST-KEYSTORE
docker run -d -p "8500:8500" -h "consul" progrium/consul -server -bootstrap

@REM - Get the generated IP-Addr for the Consul's Keystore
SET DOCKERHOST-KEYSTORE-IP-CMD="docker-machine ip DOCKERHOST-KEYSTORE"
FOR /F %i IN ( '%DOCKERHOST-KEYSTORE-IP-CMD%' ) DO  SET DOCKERHOST-KEYSTORE-IP=%i

@REM - Create a Swarm master node pointing to the the Consul address
docker-machine create -d virtualbox --swarm --swarm-master --swarm-discovery="consul://%DOCKERHOST-KEYSTORE-IP%:8500" --engine-opt="cluster-store=consul://%DOCKERHOST-KEYSTORE-IP%:8500" --engine-opt="cluster-advertise=eth1:2376" DOCKERHOST-SWARMMASTER

@REM - Create a Swarm worker node for Storing all data . This node will host data-containers
docker-machine create -d virtualbox --virtualbox-memory "3072" --swarm --swarm-discovery="consul://%DOCKERHOST-KEYSTORE-IP%:8500" --engine-opt="cluster-store=consul://%DOCKERHOST-KEYSTORE-IP%:8500" --engine-opt="cluster-advertise=eth1:2376" DOCKERHOST-STORAGE

@REM - Create a Swarm worker node for Docker local Registry to store images within the Firewall of the organizations
docker-machine create -d virtualbox --virtualbox-memory "1024" --swarm --swarm-discovery="consul://%DOCKERHOST-KEYSTORE-IP%:8500" --engine-opt="cluster-store=consul://%DOCKERHOST-KEYSTORE-IP%:8500" --engine-opt="cluster-advertise=eth1:2376" DOCKERHOST-REGISTRY

@REM - Create a Swarm worker node for hosting Applications 
docker-machine create -d virtualbox --virtualbox-memory "3072" --swarm --swarm-discovery="consul://%DOCKERHOST-KEYSTORE-IP%:8500" --engine-opt="cluster-store=consul://%DOCKERHOST-KEYSTORE-IP%:8500" --engine-opt="cluster-advertise=eth1:2376" DOCKERHOST-APP

@REM - Create a Swarm worker node for hosting Applications 
docker-machine create -d virtualbox --virtualbox-memory "2048" --swarm --swarm-discovery="consul://%DOCKERHOST-KEYSTORE-IP%:8500" --engine-opt="cluster-store=consul://%DOCKERHOST-KEYSTORE-IP%:8500" --engine-opt="cluster-advertise=eth1:2376" DOCKERHOST-CI


@REM - Create an overlay network for multi-host communication using 'overlay' driver
docker-machine env --swarm DOCKERHOST-SWARMMASTER
@FOR /f "tokens=*" %i IN ('docker-machine env --swarm DOCKERHOST-SWARMMASTER') DO @%i
docker network create --driver overlay --subnet=10.0.9.0/24 OVERLAY-NETWORK

@REM - Lsit all the nodes
docker-machine ls

@REM - List all networks
docker-machine network ls
