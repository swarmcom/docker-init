#!/bin/sh -e
NETWORK="ezuce"
FLAGS=${FLAGS:-"-td"}
MONGO_NAME=${NAME:-"mongodb.$NETWORK"}
PG_NAME=${NAME:-"postgres.$NETWORK"}
CONFIG_NAME=${NAME:-"sipxconfig.$NETWORK"}
NGINX_NAME=${NAME:-"nginx.$NETWORK"}
REG_NAME=${NAME:-"sipxregistrar.$NETWORK"}
PROX_NAME=${NAME:-"sipxproxy.$NETWORK"}

docker network create --subnet 10.6.0.0/24 $NETWORK

docker run $FLAGS \
	--name mongo \
  -h $MONGO_NAME \
  -p 27017:27017 \
  -v `pwd`/etc/mongodb.conf:/etc/mongo.config \
  -v `pwd`/mongo-data/data:/data/db \
	--network=$NETWORK \
	--ip='10.6.0.2' \
  mongo mongod --config /etc/mongo.config

sleep 10s

docker exec -it mongo mongo --eval 'rs.initiate()'

docker run $FLAGS \
 --name postgres \
 -h $PG_NAME \
 -p 5432:5432 \
 --network=$NETWORK \
 --ip='10.6.0.3' \
 -v `pwd`/pg-data/pgdata:/var/lib/postgresql/data \
 $NETWORK/postgres

docker run $FLAGS \
 --name sipxconfig \
 --add-host="mongodb.ezuce:10.6.0.2" \
 --add-host="postgres.ezuce:10.6.0.3" \
 --network=$NETWORK \
 --ip='10.6.0.4' \
 -h $CONFIG_NAME \
 -p 12000:12000 \
 $NETWORK/sipxconfig


 docker run $FLAGS \
  --name sipxregistrar \
  --add-host="mongodb.ezuce:10.6.0.2" \
  --add-host="postgres.ezuce:10.6.0.3" \
  --add-host="sipxconfig.ezuce:10.6.0.4" \
  -h $REG_NAME \
	--network=$NETWORK \
  --ip='10.6.0.5' \
  -p 5070:5070 \
  -p 5075:5075 \
  -p 5077:5077 \
  $NETWORK/sipxregistrar



	docker run $FLAGS \
	 --name sipxproxy \
	 --add-host="mongodb.ezuce:10.6.0.2" \
	 --add-host="sipxconfig.ezuce:10.6.0.4" \
	 -h $PROX_NAME \
	 --network=$NETWORK \
   --ip='10.6.0.6' \
	 -p 5060:5060 \
	 -p 5061:5061 \
	 $NETWORK/sipxproxy
