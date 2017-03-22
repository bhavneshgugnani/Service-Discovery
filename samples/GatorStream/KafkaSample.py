import threading, logging, time


from kafka import KafkaConsumer
from kafka import KafkaProducer

class Producer(threading.Thread):

    daemon = True

    def run(self):
        prod = KafkaProducer(bootstrap_servers='localhost:9092')

        while True:
            prod.send('topic1', b'msg1')
            prod.send('topic1', b'msg2')
            time.sleep(1)


class Consumer(threading.Thread):

    daemon = True

    def run(self):
        cons = KafkaConsumer(bootstrap_servers='localhost:9092',
                             auto_offset_reset='earliest')

        cons.subscribe(['topic1'])

        for msg in cons:
            print msg


def main():
    threads = [
        Producer(),
        Consumer()
    ]
    for t in threads:
        t.start()

    time.sleep(10)


if __name__ == "__main__":
    logging.basicConfig(
        format='%(asctime)s.%(msecs)s:%(name)s:%(thread)d:%(levelname)s:%(process)d:%(message)s',
        level=logging.INFO
        )
    main()