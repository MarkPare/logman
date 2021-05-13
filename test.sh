#!/bin/bash

docker run -v $(pwd):/app/ logman /bin/bash -c "mix test"
