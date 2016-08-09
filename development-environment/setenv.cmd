@echo off
set DOCKER_HOST=tcp://127.0.0.1:2375
set HTTP_ROUTER=http://127.0.0.1.xip.io:8080
set FLEETCTL_TUNNEL=127.0.0.1:2222
set DOCKER_TLS_VERIFY=

echo the following env vars have been set. Please check your VM port mappings
echo DOCKER_HOST=%DOCKER_HOST%
echo HTTP_ROUTER=%HTTP_ROUTER%
echo FLEETCTL_TUNNEL=%FLEETCTL_TUNNEL%
