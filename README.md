# Logman

## Overview
`Logman` is a simple elixir app that leverages distributed elixir to log messages across multiple nodes. This implementation uses `docker-compose` to simulate nodes running on different hosts, with 3 containers running simultaneously, each with a `Logman` instance. Each instance exposes an http interface with a single `/event` endpoint for incoming messages.

## Setup

### Requirements
Make sure you have `elixir`, `docker-compose` and their respective dependencies installed on your host machine.

### Quick setup
`./run.sh`

NOTE: This script will attempt to build the image each time it's run, which can take a little time. If the image is already built on your machine, see the `Step by step setup` section below for some one-off commands to get things up and running faster.

If containers exit with non-zero status code on first try, run command again. See note below in `Run containers` section for why sometimes containers can fail on first startup.

### Step by step setup

### 1. Build docker image
`docker build -t logman .`  

### 2. Install and compile deps on host machine
`mix deps.get && mix deps.compile && mix compile`

NOTE: with this setup, you need to install and compile deps on host machine. Some of the reasons for needing to do this in development environment when running elixir in docker are outlined in [this article](http://mroach.com/2020/07/elixir-development-with-docker/).

### 4. Run containers
`docker-compose up`

NOTE: on first time running `docker-compose up`, you may see containers exit with a non-zero status code. I didn't have time to debug this thoroughly, but I believe it happens because of non-deterministic behavior of files in `_build` directory that can occur when all 3 containers are trying to initialize simultaneously for the first time (e.g. at least once the stack trace showed `File.Error could not write to file "/app/_build/dev/lib/plug_cowboy/ebin/Elixir.Plug.Cowboy.beam": no such file or directory`). The issue was always fixed for me by stopping containers (`ctrl + c`) and restarting (`docker-compose up`).

### 5. Use app
`Logman` uses `cowboy` and `plug` to service http requests. Each node/container is run on its own port. The url for the logging endpoint for each container is as follows:

`node_1`: `http://localhost:5555/event`\
`node_2`: `http://localhost:5556/event`\
`node_3`: `http://localhost:5557/event`

To make a request to `node_1`:\
`curl -X POST --data "some message" http://localhost:5555/event`

Upon receiving the request, `node_1` will log the message "locally" (in a subdirectory specified in `Logman.Handler.get_log_file_path`, which will be distinct for each node), and also send message to all other nodes (`node_2` and `node_3` in this case) to be logged, using distributed elixir and `Task` api for communication across nodes.

The same applies for requests to other nodes (e.g. a request to `node_2` endpoint will log message "locally" on `node_2` and also send message to `node_1` and `node_3` to be logged).

### 4. Testing

To run tests within container:\
`./test.sh`

Testing is less robust than I would like. Currently there is no testing for sending messages to other nodes, mostly because of challenges in setting up testing with multiple nodes. I tried using [LocalCluster](https://github.com/whitfin/local-cluster) lib, which is designed to simplify creation of nodes for testing. However things get complicated when each node is running an http server and you get `address in use` errors. I didn't have time to delve into this more deeply, though I believe there are solutions.

## Other comments
The approach here uses `docker-compose` to run each node as a container, though I'd like to explore running multiple nodes in a single container. I didn't take this approach here because 1) I wanted to simulate running nodes across multiple hosts and 2) it didn't feel like idiomatic usage of docker.
