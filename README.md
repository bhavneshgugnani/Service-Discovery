# ServiceDiscovery
Service Discovery framework

This is the README file for Service Discovery framework


========================REQUIREMENTS========================= 

1. Downlaod tweepy from github
2. Install tweepy in machine by running "python setup.py install" inside tweepy dir
3. Check if tweepy is installed by going into python REPL and type "import tweepy"
4. pip install --upgrade ndg-httpsclient
5. pip install kafka-python



========================Building Kafka and Zookeeper images=========== 

1. Move to ./resources directory (this is context of build for docker image)
2. Copy a deployment(/binaries) of kafka to ./package/<here>
3. Execute "docker build -f <Kafka|Zookeeper>Dockerfile -t bhavneshgugnani/<kafka|zookeeper> ." to create corresponding kafka or zookeeper images
4. Run using command "docker run -i -t bhavneshgugnani/<zookeeper|kafka>"



====================Building Tweet Producer and Consumer images========== 

1. Move to ./tweet-service/<producer|consumer> directory (this is context of build for docker image)
2. Execute "docker build -f <Producer/Consumer>Dockerfile -t bhavneshgugnani/<producer|consumer> ."



==========================Linking containers============================ 

1. While building any image out of above 4, always link to other containers when building images
2. To link, for build add parameter "--link <remotecontainername>:<aliasname>". This makes IP entry of remotecontainer in /etc/hosts in current container
3. Keywords for containers : zookeeper|broker|consumer|producer (These names are referred by properties file for consumer|producer|kafka broker to ret IP of remote container)
** For start, linking has been done between containers so that they resolve IP based on remote container nameprovided during build time. Later, will integrate docker-compose for same.



===================Running with compose in docker-machine instances(MANUAL-OLD)============== 

1. Push new images to docker hub using "./linked-clster.sh push"
2. Run docker-machine instances for making cluster.
3. Add nodes to swarm cluster and assing them as manager/worker node
4. (MANUAL STEP) Copy ./docker-pull.yml file to one of manager nodes ("scp ./docker-pull.yml docker@<node_ip>:/home/docker")
5. (MANUAL STEP) SSH into manager node and install docker-compose ("wget https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)"), make it as executable and move to /usr/local/bin
6. Run compose as "docker-compose -f docker-pull.yml up"
LIMITATIONS : Manual steps; only single instances of each service(wait-for-it.sh);



==================Running compose on docker-machine with script(SINGLE FIRE)================== 

1. Push new images to docker hub using "./linked-clster.sh push"
2. Fire ./launch-compose-on-swarm.sh
3. For adding dynamic scaling of nodes, launch with "docker-compose -f docker-pull.yml scale <service>=<num>"
LIMITATIONS : Only single consumer can run for now (seems kafka limitation); all container are run on a single worker node








DOC elements pending
1. UML diagrams of Analystics infrastructure As A Platform(AAAP) with application layer, (docker) interface layer, infrastructure, etc -> Yogesh
2. Learning from project, problems/limitations, proposed better designs -> Bhavnesh
3. Mention connectors support for on boarding multiple data platforms on this AAAP 



