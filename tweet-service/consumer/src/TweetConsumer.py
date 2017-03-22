'''
1. Arguments : kafka url : localhost : topic;
'''

from kafka import KafkaConsumer
import threading
import sys

KAFKA_SERVER_IP = 'broker'
KAFKA_SERVER_PORT = '9092'
TOPIC = 'Trump'

def createConsumer():
    KAFKA_SERVER = KAFKA_SERVER_IP + ":" + KAFKA_SERVER_PORT
    cons = KafkaConsumer(bootstrap_servers=KAFKA_SERVER,
                         auto_offset_reset='earliest')
    cons.subscribe([TOPIC])
    file=open("./tweets.txt", "w+")
    for msg in cons:
        print msg
        file.write(str(msg))

if __name__ == "__main__":
    try:
        KAFKA_SERVER_IP = sys.argv[1]
        KAFKA_SERVER_PORT = sys.argv[2]
        TOPIC = sys.argv[3]
    except (IndexError, Exception) as e:
        print("Error taking arguments. Taking default values.", e)
        pass
    createConsumer()
