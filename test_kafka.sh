#!/bin/bash

set -eu

clean() {
  set +e
  docker stop kafka-producer-test > /dev/null 2>&1
  docker rm kafka-producer-test > /dev/null 2>&1
  docker stop kafka-consumer-test > /dev/null 2>&1
  docker rm kafka-consumer-test > /dev/null 2>&1
  echo "Kafka producer & consumer containers removed"
}

trap clean EXIT

# Create Kafka deployment
docker compose --env-file .env.test \
  up \
  --detach \
  --remove-orphans \
  zookeeper kafka

# Wait for Kafka to finish initialization
sleep 30s

# Build Python image for Kafka producer & consumer
docker build -t test-kafka test_kafka

# Run Kafka producer test
docker run \
  --detach \
  --name kafka-producer-test \
  --network host \
  test-kafka \
  python producer.py

# Check Kafka producer exit code
PRODUCER_EXIT_CODE=$(docker wait kafka-producer-test)
if [[ $PRODUCER_EXIT_CODE == "0" ]]; then
  echo "Kafka producer test succeeded"
else
  echo "Kafka producer test failed"
  exit 0
fi

# Run Kafka consumer test
docker run \
  --detach \
  --name kafka-consumer-test \
  --network host \
  test-kafka \
  python consumer.py

# Check Kafka consumer exit code
CONSUMER_EXIT_CODE=$(docker wait kafka-consumer-test)
if [[ $CONSUMER_EXIT_CODE == "0" ]]; then
  echo "Kafka consumer test succeeded"
else
  echo "Kafka consumer test failed"
  exit 0
fi

# Destroy Kafka deployment
docker compose --env-file .env.test \
  down \
  --volumes \
  --remove-orphans

echo "Kafka test completed successfully"
