#! /bin/bash

function docker-compose (){
docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$PWD:$PWD" \
    -w="$PWD" \
    docker/compose:1.24.0 $1 $2 $3 $4
}

services=("zookeeper" "kafka" "identity" "vehicle" "trip" "payment" "messaging" "simulation" "eureka" "gateway")

for container in ${services[*]}
do 
docker pull gitlab.svagworks.me:5050/root/demo_3:$container
if docker images | awk '{print $2}' | awk 'NR==2' | grep $container &>/dev/null; then
echo "Updating app"
docker-compose up --no-deps -d $container &>/dev/null &
elif docker ps | grep -q $container; then
echo "Running $container";
else
echo "Starting $container"
docker-compose up --no-deps -d $container &>/dev/null &
fi
done

echo "Deleting unused images"
docker image prune -a -f

echo "Checking active containers, please hold on..."
sleep 20
docker-compose ps
