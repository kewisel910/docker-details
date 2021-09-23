DIR=docker-report
HISTORY_DIR=$DIR"/history"
INSPECT_DIR=$DIR"/inspect"
NETWORK_DIR=$DIR"/network"
SERVICE_DIR=$DIR"/service"
mkdir $DIR $HISTORY_DIR $INSPECT_DIR $NETWORK_DIR $SERVICE_DIR

DOCKER_SWARM_STATUS=`docker info|grep -i swarm|awk '{print $2}'`

docker info >> $DIR/docker.info
docker config ls >> $DIR/docker.config
docker ps -a >> $DIR/docker.containers
docker network ls >> $DIR/docker.networks
docker image ls >> $DIR/docker.images

# DOCKER IMAGE HISTORY and INSPECT
#docker_images=`docker image ls|awk 'NR>1 {print $1 " " $3}'`
docker_images=$(docker image ls|awk 'NR>1 { print $3 }'|sed --expression='s/\//-/g')
for image in $docker_images
do 
	#image_id=$(echo $images | awk '{print $1}')
	#image_name=$(echo $images | awk '{print $2}'|sed --expression='s/\//-/g')
	docker image history $image >> $HISTORY_DIR/${image}.history
	docker inspect $image >> $INSPECT_DIR/${image}.inspect
done

# DOCKER PORTS EXPOSED
for container in `docker container ls | awk 'NR>1 {print $1 }'`
do
	echo `docker port $container` >> $DIR/docker.ports
done

# DOCKER NETWORK INSPECT
for net in `docker network ls | awk 'NR>1 {print $2}'`
do
	echo `docker network inspect ${net}` >> $NETWORK_DIR/${net}.json
done

# DOCKER SWARM
if [ $DOCKER_SWARM_STATUS="active" ];
then
	# DOCKER SERVICES
	docker service ls >> $DIR/docker.service
	# DOCKER SERVICE INSPECT
	for service in `docker service ls | awk 'NR>1 {print $2}'`
		do
		echo `docker service inspect ${service}` >> $SERVICE_DIR/${service}.json
	done
fi

tar cvzf docker-report.tar.gz docker-report/
