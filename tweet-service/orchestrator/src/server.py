from flask import Flask
from enum import Enum
from pymongo import MongoClient
from datetime import datetime
import os

class ServiceTypes(Enum):
    tweet_text = 1
    hashtags = 2
    user_mentions = 3
    coordinates = 4
    created_at = 5
    retweet_count = 6
    user = 7
    track_place = 8

def registerWithMongoDB(user, source, attr, text):
    client = MongoClient('mongodb', 27017)
    mydb = client['test_database']
    my_collection = mydb['test-collection']
    myrecord = {
        "user_name": user,
        "source": source,
        "type": attr,
        "text": text,
        "state": False,
        "container_type": "producer",
        "date": datetime.utcnow()
    }
    record_id = my_collection.insert(myrecord)
    print "inserted with record-id " + str(record_id)

    print my_collection.find({"text": text}).limit(1)
    print my_collection.find({"_id": str(record_id)}).limit(1)

def startInstance(instanceType):
    # Read /etc/hosts to find master IP
    master_ip = "localhost"
    f = open("/etc/hosts")
    for line in f:
        if line.__contains__("master"):
            print line.split(" ")[0]
            master_ip = line.split(" ")[0]
    print "MASTER IP FOUND : " + master_ip
    # point docker to master
    os.system("eval $(docker-machine env --swarm master)")

    print "DOCKER POINTING TO COMPOSE"
    # inspect docker-compose to get # of containers running and scale up by 1
    # os.system("docker-compose inspect --format {{}}")

    # docker scale to increase container count
    os.system("docker ps")
    os.system("docker-compose scale " + instanceType + "=2")
    os.system("docker ps")

    # point docker back to local
    os.system("eval $(docker-machine env -u)")


app = Flask(__name__)

@app.route('/')
def index():
    return "This is Home"

@app.route('/<user>/filter/<source>/<attr>/<text>', methods=[ 'GET' ])
def launchFilterInstance(user, source, attr, text):

    #STEP 1 : Register request with mongo-db
    registerWithMongoDB(user, source, attr, text)

    # STEP 2 : Start new instance
    startInstance("producer")

    return "started producer!"

@app.route('/<user>/process/<source>/<attr>/<text>', methods=[ 'GET' ])
def launchProcessInstance(user, source, attr, text):

    registerWithMongoDB(user, source, attr, text)

    startInstance("consumer")

    return "Started Consumer!"

if __name__ == "__main__":
    app.run(host='0.0.0.0')

