#!/bin/sh

# NOTE: Uses application-prod.properties and logback-env-prod.groovy
# See "PROD" in every log line.
java -Dspring.profiles.active=prod -jar ./app.jar

