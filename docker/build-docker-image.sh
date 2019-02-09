#!/usr/bin/env bash

if [ $# -ne 1 ]
then
    echo "Usage: ./build-docker-image.sh <path-to-app-jar>"
    echo "Example: ./build-docker-image.sh /home/aw/pc/git/java-simple-rest-demo-app/build/libs/java-simple-rest-demo-app-0.1.0.jar"
    exit 1
fi

APP_PATH=$1
MY_IMAGE_NAME=tieto-pc/java-crm-demo
MY_IMAGE_VERSION=0.1

CMD_BUILD="docker build -f Dockerfile -t $MY_IMAGE_NAME:$MY_IMAGE_VERSION ."

cp $APP_PATH image/app.jar
mkdir -p image/resources
cp -r ./resources/* image/resources/.
cd image
echo "Building docker image $MY_IMAGE_NAME:$MY_IMAGE_VERSION ..."

$CMD_BUILD
echo "Done with image $MY_IMAGE_NAME:$MY_IMAGE_VERSION"
echo "Cleaning ..."
rm -rf resources
rm *.jar
cd ..
echo "All Done"
