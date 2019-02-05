#!/bin/bash

echo "When container has started you can curl it like:"
echo "curl http://localhost:5055/customer/1"
echo "Starting container..."

# Overriding default entrypoint.
docker run -it -p5055:5055 --entrypoint "./run-prod-mode.sh" tieto-pc/java-crm-demo:0.1

