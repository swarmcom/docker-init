#!/bin/sh -e
FLAGS=${FLAGS:-"-td"}
NETWORK=${NETWORK:-"ezuce"}
MONGO_NAME=${NAME:-"mongodb.$NETWORK"}
PG_NAME=${NAME:-"postgres.$NETWORK"}
CONFIG_NAME=${NAME:-"sipxconfig.$NETWORK"}
NGINX_NAME=${NAME:-"nginx.$NETWORK"}

docker run $FLAGS \
	--name mongo \
  -h $MONGO_NAME \
  -p 27017:27017 \
  -v `pwd`/etc/mongodb.conf:/etc/mongo.config \
  -v `pwd`/mongo-data/data:/data/db \
  mongo mongod --config /etc/mongo.config

sleep 10s

docker exec -it mongo mongo --eval 'rs.initiate()'

docker run $FLAGS \
 --name postgres \
 -h $PG_NAME \
 -p 5432:5432 \
 -v `pwd`/pg-data/pgdata:/var/lib/postgresql/data \
 $NETWORK/postgres

docker run $FLAGS \
 --name sipxconfig \
 --link mongo:mongodb.ezuce \
 --link postgres:postgres.ezuce \
 -h $CONFIG_NAME \
 -p 12000:12000 \
 $NETWORK/sipxconfig

docker run $FLAGS \
	--name nginx \
  -h $NGINX_NAME \
	--link sipxconfig:sipxconfig.ezuce \
  -p 80:80 \
	-v `pwd`/etc/sipxconfig.conf:/etc/nginx/conf.d/default.conf \
  nginx
