#!/bin/bash

echo "When container has started you can curl it like:"
echo "curl http://localhost:5055/customer/1"
echo "Starting container..."

docker run -it -p5055:5055 tieto-pc/java-crm-demo:0.1
