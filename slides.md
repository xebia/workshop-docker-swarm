<!-- .slide: data-background="#6B205E" -->
<center><div style="width: 75%; height: auto;"><img src="img/xebia.svg"/></div></center>

!SLIDE
## Docker Swarm - A complete Docker Container Platform
<center>
<p><img src="img/docker-logo-no-text.png" style="border: none; background: none; box-shadow: none;"/></p>
</center>
    **Mark van Holsteijn** - <a href="mailto:mvanholsteijn@xebia.com">mvanholsteijn@xebia.com</a><br/>
    **Slides** - [http://xebia.github.io/workshop-docker-swarm](http://xebia.github.io/workshop-docker-swarm)
</center>

!SUB
## Why? It Supports True DevOps!
<center><div style="width: 75%; height: auto;"><img src="img/true-devops.jpg"/></div></center>


!SLIDE
## Docker Swarm Commands
- Configuration
- Services
- Network

!SUB
## Swarm configuration
Creating swarm clusters.

```
  init        Initialize a swarm
  join        Join a swarm as a node and/or manager
  join-token  Manage join tokens
  update      Update the swarm
  leave       Leave a swarm
```

!SUB
## Service definitions
Defining applications you want to have running.

```
  create      Create a new service
  inspect     Display detailed information on one or more services
  ps          List the tasks of a service
  ls          List services
  rm          Remove a service
  scale       Scale one or multiple services
  update      Update a service
```

!SUB
## Network commands
Creating application specific networks.
```
  connect     Connect a container to a network
  create      Create a network
  disconnect  Disconnect a container from a network
  inspect     Display detailed information on one or more networks
  ls          List networks
  rm          Remove a network
```

!SLIDE
### The hands-on result
<p>This is your end result today!</p>
<center>![Docker Swarm Cluster](img/hands-on-setup.png)</center>

!SLIDE
### Hands-on 
- generic instruction, try to solve it yourself
- are you stuck? press 's' and check the presenter notes for typing instructions

**Prerequisites**
- Docker experience
- Vagrant 1.6.0 or Higher
- VirtualBox 5.0 or Higher
- 4-8 Gb memory free


!SLIDE
### Local paas-monitor application

<p style="font-size: 80%">
paas-monitor is a small docker application that allows you to see
the effect of rolling upgrades, scaling, failures etc. the environment variables
'RELEASE' and 'MESSAGE' can be used to mimick new application releases.
<br/>
</p><hr/><p style="font-size: 80%">
** Assignment : **
run the docker image mvanholsteijn/paas-monitor:latest, exposing its port 1337 and point your browser to it.
 what do you see? what happens if you stop the paas-monitor?
</p>
<p>
<center>![paas-monitor](img/paas-monitor.png)</center>
</p>

!NOTE
- docker-machine create -d virtualbox  dev
- eval $(docker-machine env dev)
- docker run -d --publish :1337:1337 --env "RELEASE=v1" --env "MESSAGE=hello from docker machine." mvanholsteijn/paas-monitor:latest
- open http:$(echo $DOCKER_HOST | cut -d: -f2):1337
- docker stop $(docker ps -ql)

!SLIDE
## Getting Started

<p>We created a vagrant setup consisting of 4 Ubuntu 16.04 LTS virtual machines on VirtualBox on 
https://github.com/xebia/workshop-docker-swarm.git in the directory 'development-environment'

<img src="img/vagrant-setup.png" style="border: none; background: none; box-shadow: none;"/>
</p>

!NOTE
- git clone https://github.com/xebia/workshop-docker-swarm.git
- cd workshop-docker-swarm/development-environment
- vagrant up


!SLIDE
### Initialize the swarm 
<p style="font-size: 75%">
The 'docker swarm init' allows you to initialize a cluster and create your first manager.
</p><hr/><p style="font-size: 80%">
** Assignment: **
Login to node-01, initialize your swarm and start node-01 as a swarm manager.
<img src="img/swarm-manager-only.png" style="border: none; background: none; box-shadow: none;"/>
</p>

!NOTE
- vagrant ssh node-01
- docker swarm init --advertise-addr 172.17.8.101

!SLIDE
### Add the swarm workers
<p style="font-size: 75%">
The 'docker swarm join' command allows you to add workers to the swarm. The 'docker node' command allows you view all nodes in the Swarm.
</p><hr/><p style="font-size: 80%">
** Assignment: **
Add node-02 through node-04 as workers to your Swarm. When you are done, list the nodes in the swarm.

<img src="img/swarm-complete.png" style="border: none; background: none; box-shadow: none;"/>
</p>

!NOTE
- vagrant ssh node-02 -- docker swarm join --token $(vagrant ssh node-01 -- docker swarm join-token -q worker) 172.17.8.101:2377
- vagrant ssh node-03 -- docker swarm join --token $(vagrant ssh node-01 -- docker swarm join-token -q worker) 172.17.8.101:2377
- vagrant ssh node-04 -- docker swarm join --token $(vagrant ssh node-01 -- docker swarm join-token -q worker) 172.17.8.101:2377
- vagrant ssh node-01 -- docker node ls

!SLIDE
### Create an overlay network

<p style="font-size: 75%">
The 'docker network create' command allows you to create an overlay network for your application which spans the machines in the swarm.
** Assignment: **
create an overlay network named 'network1'.  When you are done, list all the available networks.
</p><hr/><p style="font-size: 80%">
<img src="img/swarm-network.png" style="border: none; background: none; box-shadow: none;"/>
</p>

!NOTE
- vagrant ssh node-01 -- docker network create --driver overlay network1
- vagrant ssh node-01 -- docker network ls

!SLIDE
### Create the paas-monitor service
<p style="font-size: 75%">
The 'docker service create' command allows you to create services that are deployed on the Swarm. 'docker scale' allows you
to scale the number of instances. The overlay network allows
</p><hr/><p style="font-size: 80%">
** Assignment: **
Create the service paas-monitor for the docker application mvanholsteijn/paas-monitor:latest on the network 'network1'. Expose
port 1337 as port 80. Start with 1 instance. Open the browser on http://172.17.8.101. Scale to 3 instances. What do you see? On which 
nodes is the paas-monitor running? 

<img size="50%" src="img/swarm-complete.png" style="border: none; background: none; box-shadow: none;"/>
</p>


!NOTE
- vagrant ssh node-01 -- docker service create --name paas-monitor --env RELEASE=v1 --replicas 1 --network paas-monitor -p :80:1337/tcp  mvanholsteijn/paas-monitor:latest
- open http://172.17.8.101
- vagrant ssh node-01 -- docker scale paas-monitor=3
- vagrant ssh node-01 -- docker service ps paas-monitor

!SUB
### high availability
<p style="font-size: 75%">
Swarm maintains the number of specified replicas of the application in the swarm. 
</p><hr/><p style="font-size: 80%">
** Assignment: **
Stop one of the paas-monitor instances. What do you see happen? 

<img size="50%" src="img/instance-failure.png" style="border: none; background: none; box-shadow: none;"/>
</p>


!NOTE
- open http://172.17.8.101
- vagrant ssh node-01 -- docker service ps paas-monitor
- curl http://172.17.8.101/stop
- vagrant ssh node-01 -- docker service ps paas-monitor
