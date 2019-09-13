# "ssh" into a docker container
dssh() {
    if [ -n "$1" ]
    then
            docker exec -it $@ /bin/bash
    fi
}

# execute a command into a docker container
dexec() {
    if [ -n "$1" ]
    then
            docker exec -it $@
    fi
}

# bring up docker-containers and run them in the background
dls() {
    docker container ls $@
}

# jump into the logs of a docker container
dlog() {
    docker logs -f $@
}

# bring up docker-containers and run them in the background
dstart() {
    docker container start $@
}

# stop a set of docker containers
dstop() {
    docker container stop $@
}

# jump into the logs of the docker-containers
dlog() {
    docker container logs -f $@
}

# stop and kill the current docker containers
drm() {
    docker container stop $@ && docker rm -f $@
}

# bring up docker-containers and run them in the background
dcup() {
    docker-compose up -d $@
}

# stop a set of docker containers
dcstop() {
    docker-compose stop $@
}

# jump into the logs of the docker-containers
dclog() {
    docker-compose logs -f $@
}

# stop and kill the current docker containers
dcrm() {
    docker-compose stop && docker-compose rm -f $@
}
