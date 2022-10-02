#!/bin/bash

echo "Running Maven in Docker..."
docker run --rm -v maven-3.8.6-openjdk-8-slim-cache:/root/.m2 -w /app -v $(pwd):/app maven:3.8.6-openjdk-8-slim mvn "$@"
