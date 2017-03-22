
#!/bin/bash

# THIS SCRIPT CREATES A SWARM AND RUNS COMPOSE APPLICATION ON IT USING AN OVERLAY NETWORK UNDER THE HOOD 

# Parameters for script
keystore="keystore"
network="compose-network"
master="master"
worker1="worker1"
worker2="worker2"
visualiser="visualiser"

# HIGH LEVEL DEPLOYMENT IDEA 
# STEP 1 : Set-up global key-value store instance like consul, zookeeper, Etcd, etc
# STEP 2 : Create Swarm cluster 
# STEP 3 : Create overlay network
# STEP 4 : Run application on network 

# Utility functions for each step
cleanup() {
  # STEP 0 : CLEANUP TO AVOID ANY CLASHES
  echo "=====================Cleaning up old docker machine instances ..."
  docker-machine rm -f $keystore
  docker-machine rm -f $master
  docker-machine rm -f $worker1
  docker-machine rm -f $worker2
}

startkeystore() {
  # STEP 1
  echo "=====================Starting Consul, global key-store instance ..."
  # Create new machine to run consul container
  docker-machine create -d virtualbox $keystore
  # Change env to key store machine
  eval "$(docker-machine env $keystore)"
  # Start consul key value store with server name "consul"
  docker run -d -p 8500:8500 -h "consul" progrium/consul -server -bootstrap
  # Point docker back to local env
  eval "$(docker-machine env -u)"
}

createswarm() {
  # STEP 2
  echo "=====================Creating Swarm cluster ..."
  # Create swarm master node
  docker-machine create -d virtualbox --swarm --swarm-master --swarm-discovery="consul://$(docker-machine ip $keystore):8500" --engine-opt="cluster-store=consul://$(docker-machine ip $keystore):8500" --engine-opt="cluster-advertise=eth1:2376" $master
  # Create worker nodes and add to swarm
  docker-machine create -d virtualbox --swarm --swarm-discovery="consul://$(docker-machine ip $keystore):8500" --engine-opt="cluster-store=consul://$(docker-machine ip $keystore):8500" --engine-opt="cluster-advertise=eth1:2376" $worker1
  #docker-machine create -d virtualbox --swarm --swarm-discovery="consul://$(docker-machine ip $keystore):8500" --engine-opt="cluster-store=consul://$(docker-machine ip $keystore):8500" --engine-opt="cluster-advertise=eth1:2376" $worker2
  docker-machine ls
  # Point docker to master node of swarm to get list of swarm nodes and all networks in swarm
  eval "$(docker-machine env --swarm $master)"
  echo "Swarm Nodes IP addresses ..."
  docker run swarm list consul://$(docker-machine ip $keystore):8500
  echo "Swarm Nodes origninal networks ..."
  docker network ls
  eval "$(docker-machine env -u)"
}

createVisualiser() {
  # STEP 2 (OPTIONAL)
  # Optional : Install visualiser container for UI view on master node
  # Point docker to master node to install visualiser
  eval "$(docker-machine env $master)"
  # start visualiser container
  docker run -it -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock --name $visualiser manomarks/visualizer
  echo "VISUALISER IP : $(docker-machine ip $master)"
  echo "VISUALISER ADDRESS : http://$(docker-machine ip $master):8080/"
  open http://$(docker-machine ip $master):8080/
  # Point docker back to local env
  eval "$(docker-machine env -u)"
}

createoverlaynetwork() {
  # STEP 3
  echo "====================Creating overlay network ..."
  # Set docker env to swarm master
  eval "$(docker-machine env --swarm $master)"
  # Create overlay network. Below command can be run on any single node in cluster(here running on manager). subnet parameter makes sure that IP assigned by docker-daemon does not clashes with IP of any other subnet in infrastructure
  docker network create --driver overlay --subnet=10.0.9.0/24 $network
  # Point docker back to local env
  eval "$(docker-machine env -u)"
}

startapp() {
  # STEP 4
  echo "====================Launching Docker Compose Application ..."
  # Point docker env to swarm master node
  eval "$(docker-machine env --swarm $master)"
  # Start application
  docker-compose -f docker-pull.yml up
  # Point docker back to local env
  eval "$(docker-machine env -u)"
}

# Execute script
cleanup
startkeystore
createswarm
#createVisualiser
# No need to create explicit overlay network as latest swarm creates one under the hood when compose is launched 
#createoverlaynetwork
startapp
