import logging

from kafka import KafkaProducer

logging.basicConfig(level=logging.INFO)


def on_send_success(record_metadata):
    logging.info('Message sent')


def on_send_error(excp):
    logging.exception('Error sending message', exc_info=excp)
    exit(1)


producer = KafkaProducer(bootstrap_servers=['localhost:9092'])
producer.send('test', key=b'text', value=b'This is a message').add_callback(on_send_success).add_errback(on_send_error)

producer.flush(timeout=5)
exit(0)
