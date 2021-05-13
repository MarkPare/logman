#!/bin/bash

docker build -t logman .

mix deps.get && mix deps.compile && mix compile

docker-compose up
