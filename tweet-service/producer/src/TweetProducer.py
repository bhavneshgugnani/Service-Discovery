from tweepy import Stream
from tweepy import OAuthHandler
from tweepy.streaming import StreamListener
from kafka import KafkaProducer
from pymongo import MongoClient
import json
import sys
import uuid
import time

'''
This is an array of strings in which OAuth keys/tokens are read into
secret_keys[0] : <comsumer_key>
secret_keys[1] : <consumer_secret>
secret_keys[2] : <authorization_token>
secret_keys[3] : <authorization_secret>
'''

secret_keys = []

'''
@keys_io:
    This method is to read OAuth keys/tokens from file
'''

TOPICS = ['Trump','Hillary','Modi','nba','football','Pokemon']
TOPIC = "Trump"

def keys_io():
    key_file = open('resources/secret.txt', 'r+')

    for key in range(1,5):
        secret_keys.append(key_file.readline().split("=")[1].strip())


if __name__ == "__main__":
    cur_uuid = uuid.uuid4()
    try:
        #TOPIC = sys.argv[1]
        client = MongoClient('mongodb', 27017)
        mydb = client['test_database']
        my_collection = mydb['test-collection']
        id=uuid.uuid4()
        for i in range(0, 5, 1):
            record=my_collection.find({ "$and" : [{"container_type" : "producer"} , {"state" : False}] }).limit(1)
            cursor=my_collection.update_one( {"$and" : [{"container_type" : "producer"} , {"state" : False}]},
                                            {"$set" : {"state" : True, "uuid" : id}})

            if cursor.acknowledged :
                print "Update Success"
                cursor=my_collection.find({"uuid": id})
                for record in cursor: # should give only single resul
                    TOPIC=record["text"];
                break
            else:
                print "Retry (%s) Update after 5 sec" %i
                time.sleep(5)

        if i == 5:
            print "Max Update retry attempts failed"
            exit()

        print "TOPIC : " + TOPIC

    except (IndexError, Exception) as e:
        print("Error taking arguments. Taking default values.", e)
        pass

    print sys.getdefaultencoding()
    keys_io()
    #auth = OAuthHandler(secret_keys[0], secret_keys[1])
    #auth.set_access_token(secret_keys[2], secret_keys[3])

    #twitterstream = Stream(auth, Listener())
    #twitterstream.filter(track=TOPICS)


class Listener(StreamListener):
    print "Starting producer for Topic : " + TOPIC
    prod = KafkaProducer(bootstrap_servers='broker:9092')
    def on_data(self, raw_data):
        try:
            #print raw_data
            tweet_text = json.loads(raw_data)
            json.dumps(tweet_text, sort_keys=True, indent=4)
            #print "Tweet: ", tweet_text['text']
            data = tweet_text['text']
            if(data.find(TOPIC) != -1):
                self.prod.send(TOPIC, (data).encode('utf-8', 'ignore'))
            return True
        except Exception as e:
            print("exception happened! : ", e)


    def on_error(self, status_code):
        print status_code

