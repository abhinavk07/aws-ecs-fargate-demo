#!/bin/sh

# NOTE: Uses application-dev.properties and logback-env-dev.groovy
# See "DEV" in every log line.
java -Dspring.profiles.active=dev -jar ./app.jar

