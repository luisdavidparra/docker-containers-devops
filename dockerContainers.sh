#!/bin/bash

docker volume create sonarqube_data
docker volume create sonarqube_extensions
docker volume create sonarqube_logs

docker volume create postgresql
docker volume create postgressql_data

docker network create atnet

mkdir ~/postgresql
mkdir ~/postgresql_data

docker run --name postgres \
  -e POSTGRES_USER=root \
  -e POSTGRES_PASSWORD=Test12345 \
  -p 5432:5432 --network atnet -d postgres

sudo sysctl -w vm.max_map_count=262144

docker run -d --name sonarqube -p 9000:9000 \
  -e sonar.jdbc.url=jdbc:postgresql://postgres/postgres \
  -e sonar.jdbc.username=root \
  -e sonar.jdbc.password=Test12345 \
  --network atnet sonarqube

docker run \
  --name jenkins-docker \
  --rm \
  --detach \
  --privileged \
  --network atnet \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind \
  --storage-driver overlay2
