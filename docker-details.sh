DIR=docker-report
HISTORY_DIR=$DIR"/history"
INSPECT_DIR=$DIR"/inspect"
NETWORK_DIR=$DIR"/network"
SERVICE_DIR=$DIR"/service"
mkdir $DIR $HISTORY_DIR $INSPECT_DIR $NETWORK_DIR $SERVICE_DIR

DOCKER_SWARM_STATUS=`docker info|grep -i swarm|awk '{print $2}'`

echo "=====================DOCKER INFO=========================" >> $DIR/docker.info
docker info >> $DIR/docker.info

echo "=====================DOCKER CONFIG=======================" >> $DIR/docker.config
docker config ls >> $DIR/docker.config

echo "=====================DOCKER CONTAINERS===================" >> $DIR/docker.containers
docker ps -a >> $DIR/docker.containers

echo "=====================DOCKER NETWORKS=====================" >> $DIR/docker.networks
docker network ls >> $DIR/docker.networks

echo "=====================DOCKER IMAGES=======================" >> $DIR/docker.images
docker image ls >> $DIR/docker.images

# DOCKER IMAGE HISTORY and INSPECT
for image in `docker image ls | awk 'NR>1 {print $1 }'`
do 
	image_name=`echo $image|sed --expression='s/\//-/g'`
	echo "=======${image}========" >> $HISTORY_DIR/$image_name.history
	docker image history $image >> $HISTORY_DIR/$image_name.history
	echo "=======${image}========" >> $INSPECT_DIR/$image_name.inspect
	docker inspect $image >> $INSPECT_DIR/$image_name.inspect
done

# DOCKER PORTS EXPOSED
echo "=====================DOCKER PORTS=====================" >> $DIR/docker.ports	
for container in `docker container ls | awk 'NR>1 {print $1 }'`
do
	echo "ID $container" >> $DIR/docker.ports
	echo `docker port $container` >> $DIR/docker.ports
done

# DOCKER NETWORK INSPECT
for net in `docker network ls | awk 'NR>1 {print $2}'`
do
	echo "========${net}========" >> $NETWORK_DIR/${net}.json
	echo `docker network inspect ${net}` >> $NETWORK_DIR/${net}.json
done

# DOCKER SWARM
if [ $DOCKER_SWARM_STATUS="active" ];
then
	# DOCKER SERVICES
	echo "===================DOCKER SERVICE=====================" >> $DIR/docker.service
	docker service ls >> $DIR/docker.service
	# DOCKER SERVICE INSPECT
	for service in `docker service ls | awk 'NR>1 {print $2}'`
		do
		echo "===========${service}===========" >> $SERVICE_DIR/${service}.json
		echo `docker service inspect ${service}` >> $SERVICE_DIR/${service}.json
	done
fi

tar cvzf docker-report.tar.gz docker-report/
