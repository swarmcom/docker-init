# docker-init

As of 14.June.2017 
./install.sh will deploy containers for sipxconfig, postgres, mongo, proxy and registrar

Additional work needs to be done to start those containers (create a routed docker network)
Note that for the moment proxy and registrar are hardcoded and you need to make manually chnages to  make them process SIP messages


How to route to your docker network... on pfsense (you should know your router)
This example assumes that you will use subnet 10.6.0.0/24 as you can see in install.sh

a. for pfsense under Gateways--> add--> Docker_test -- 192.168.1.195    (host ip address)
b.       under Static Routes --> add--> Subnet 10.6.0.0/29 -- Gateway Docker_test

ping from your LAN 10.6.0.1 
- should respond to PING since 10.6.0.1 is the docker network gateway


For developer notes read README.md under swarmcomm/docker

