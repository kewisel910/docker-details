DIR=docker-report
HISTORY_DIR=$DIR"/history"
INSPECT_DIR=$DIR"/inspect"
mkdir $DIR $HISTORY_DIR $INSPECT_DIR


echo "=====================DOCKER INFO=========================" >> $DIR/docker.info
docker info >> $DIR/docker.info

echo "=====================DOCKER CONTAINERS===================" >> $DIR/docker.containers
docker ps -a >> $DIR/docker.containers

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

tar cvzf docker-report.tar.gz docker-report/


