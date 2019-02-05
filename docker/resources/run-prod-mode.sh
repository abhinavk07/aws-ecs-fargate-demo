#!/bin/bash

# NOTE: Uses application-prod.properties and logback-env-prod.groovy
# See "PROD" in every log line.
java -Dspring.profiles.active=prod --illegal-access=deny -jar ./app.jar

