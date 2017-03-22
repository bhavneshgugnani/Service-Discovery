
#!/bin/bash
# Launches the Service Discovery cluster including building images and launching them and linking them while launching

# Utility functions to build and push specific images to hub
pushZookeeper() {
  docker build -t ${sd}/${zk}:${latest} -f ./docker-build/ZooKeeperDockerfile .
  docker push ${sd}/${zk}:${latest}
}

pushBroker() {
  docker build -t ${sd}/${broker}:${latest} -f ./docker-build/KafkaDockerfile .
  docker push ${sd}/${broker}:${latest}
}

pushProducer() {
  docker build -t ${sd}/${producer}:${latest} -f ./docker-build/ProducerDockerfile .
  docker push ${sd}/${producer}:${latest}
}

pushConsumer() {
  docker build -t ${sd}/${consumer}:${latest} -f ./docker-build/ConsumerDockerfile .
  docker push ${sd}/${consumer}:${latest}
}

pushOrchestrator() {
  docker build -t ${sd}/${orchestrator}:${latest} -f ./docker-build/OrchestratorDockerfile .
  docker push ${sd}/${orchestrator}:${latest}
}

pushMongodb() {
  docker build -t ${sd}/${mongodb}:${latest} -f ./docker-build/MongodbDockerfile .
  docker push ${sd}/${mongodb}:${latest}
}

# Variables. Kind of hardcoded based on names in properties file for kafka.
sd="bhavneshgugnani"
latest="latest"
zk="zookeeper"
broker="broker"
producer="producer"
consumer="consumer"
orchestrator="orchestrator"
mongodb="mongodb"

# Stop and Remove local container/images for avoiding clash
echo "CLEANING UP OLD IMAGES."
docker stop ${zk}
docker stop ${broker}
docker stop ${producer}
docker stop ${consumer}

docker rm -f ${zk} 
docker rm -f ${broker}
docker rm -f ${producer}
docker rm -f ${consumer}

docker rmi ${sd}/${zk}
docker rmi ${sd}/${broker}
docker rmi ${sd}/${producer}
docker rmi ${sd}/${consumer}
echo "CLEANUP COMPLETE."

if [ "$1" == "start" ]; then
  # Build fresh images
  echo "BUILDING FRESH IMAGES."
  docker build -t ${sd}/${zk}:${latest} -f ./docker-build/ZooKeeperDockerfile .
  docker build -t ${sd}/${broker}:${latest} -f ./docker-build/KafkaDockerfile .
  docker build -t ${sd}/${producer}:${latest} -f ./docker-build/ProducerDockerfile .
  docker build -t ${sd}/${consumer}:${latest} -f ./docker-build/ConsumerDockerfile .
  docker build -t ${sd}/${orchestrator}:${latest} -f ./docker-build/RestServerDockerfile .
  echo "IMAGES BUILD."

  # Launch images in order and link. The names are somewhat hardcoded becuase of values in properties file for kafka
  echo "STARTING CLUSTER COMPONENTS."
  docker run -d --name ${zk} ${sd}/${zk}:${latest}
  docker run -d --name ${broker} --link ${zk}:${zk} ${sd}/${broker}:${latest}
  # This is a trick so broker can start before producer tries to start
  echo "Sleeping for 2 seconds so broker can be online while producer starts"
  sleep 2
  docker run -d --name ${producer} --link ${broker}:${broker} ${sd}/${producer}:${latest}
  docker run -d --name ${consumer} --link ${broker}:${broker} ${sd}/${consumer}:${latest}
  echo "CLUSTER SUCCESSFULLY STARTED. YOU CAN SSH INTO CONTAINERS TO VIEW TWEETS/LOGS."
elif [ "$1" == "push" ]; then
  if [ "$2" ]; then
    if [ "$2" == "zookeeper" ]; then
      echo "Pushing $2"
      pushZookeeper
    elif [ "$2" == "broker" ]; then
      echo "Pushing $2"
      pushBroker
    elif [ "$2" == "producer" ]; then
      echo "Pushing $2"
      pushProducer
    elif [ "$2" == "consumer" ]; then
      echo "Pushing $2"
      pushConsumer
    elif [ "$2" == "orchestrator" ]; then
      echo "Pushing $2"
      pushOrchestrator
    elif [ "$2" == "mongodb" ]; then
      echo "Pushing $2"
      pushMongodb
    else
      echo "Unknown image."
      exit -1
    fi
  else
    echo "Pushing all latest images to hub."
    pushZookeeper
    pushBroker
    pushProducer
    pushConsumer
    pushOrchestrator
    pushMongodb
  fi
fi