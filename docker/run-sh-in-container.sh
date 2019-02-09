#!/bin/bash

docker run -it -p5055:5055 --workdir="/opt/mylib" --entrypoint /bin/sh tieto-pc/java-crm-demo:0.1
