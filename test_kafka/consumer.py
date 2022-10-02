import logging

from kafka import KafkaConsumer

logging.basicConfig(level=logging.INFO)

consumer = KafkaConsumer('test',
                         group_id='test-consumer-group',
                         bootstrap_servers=['localhost:9092'],
                         auto_offset_reset='earliest',
                         consumer_timeout_ms=5000)
message = next(consumer)
logging.info('Message received')
logging.info(f"Key: {message.key}")
logging.info(f"Value: {message.value}")
exit(0)
