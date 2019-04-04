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
dup() {
    docker-compose up -d $@
}

# stop a set of docker containers
dstop() {
    docker-compose stop $@
}

# jump into the logs of the docker-containers
dlog() {
    docker-compose logs -f $@
}

# stop and kill the current docker containers
drm() {
    docker-compose stop && docker-compose rm -f $@
}