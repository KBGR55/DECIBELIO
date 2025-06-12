#!/bin/bash

cd ../decibelio

# Config Java 17
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

./mvnw clean package
