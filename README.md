# docker-janus
`docker-janus` is a Debian 10 based docker image for [Meetecho's Janus Gateway](https://github.com/meetecho/janus-gateway)

## Description

You can use this image directly from [hub.docker.com](https://hub.docker.com/r/jemmic/docker-janus/) by issuing the following docker commands:
```
docker pull jemmic/docker-janus:latest
```

Many thanks for [meetecho](http://www.meetecho.com) for providing us [Janus Gateway](https://github.com/meetecho/janus-gateway)!

We have tried to build the image with docker best practices at hand. Should there be anything of note you notices, please do not hesitate to leave a comment!

## quickstart 
```
$ git clone https://github.com/jemmic/docker-janus.git
Cloning into 'docker-janus'...
remote: Counting objects: 69, done.
remote: Compressing objects: 100% (53/53), done.
remote: Total 69 (delta 19), reused 59 (delta 13), pack-reused 0
Unpacking objects: 100% (69/69), done.
Checking connectivity... done.
$ cd docker-janus/
$ docker-compose up -d
Creating network "dockerjanus_front-tier" with driver "bridge"
Creating network "dockerjanus_back-tier" with driver "bridge"
Pulling janus-gateway (jemmic/docker-janus:latest)...
latest: Pulling from jemmic/docker-janus
43c265008fae: Pull complete
9ee7f339f682: Pull complete
Digest: sha256:2ad4234b7255b52150d06ac231edff635102fa47c90f714b66ae37885f9f64d3
Status: Downloaded newer image for jemmic/docker-janus:latest
Creating janus-gateway
$ docker-compose ps
    Name              Command          State                       Ports                      
---------------------------------------------------------------------------------------------
janus-gateway   /opt/janus/bin/janus   Up      0.0.0.0:8088->8088/tcp, 0.0.0.0:8188->8188/tcp 
$ docker images
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
jemmic/docker-janus   latest              1dd697edcb76        23 minutes ago      232.9 MB
$ 
```

Visiting `http://localhost:8088/janus/info` in your browser should provide you with the build info of janus in JSON format.

A full set of default janus config files are in `./janus` folder, which is referenced as a volume in the `docker-compose.yml` file for docker-compose to use. 

## build criteria
`janus-gateway` is built with the following configured options disabled, as I do not have the need for them to be enabled by default:
```
./configure --prefix=/opt/janus --enable-post-processing --disable-docs --enable-boringssl --enable-dtls-settimeout --disable-data-channels --disable-websockets --disable-mqtt --disable-unix-sockets --disable-rabbitmq
```

## default build
There is a `Makefile`, with some directives on building janus. Have a look at that file and check the options. Issuing a `make` will run the default build with the options set below.

```
DataChannels support:      no
BoringSSL (no OpenSSL):    yes
Recordings post-processor: yes
TURN REST API client:      yes
Doxygen documentation:     no
Transports:
    REST (HTTP/HTTPS):     yes
    WebSockets:            no (new API)
    RabbitMQ:              no
    MQTT:                  no
    Unix Sockets:          no
Plugins:
    Echo Test:             yes
    Streaming:             yes
    Video Call:            yes
    SIP Gateway:           yes
    Audio Bridge:          yes
    Video Room:            yes
    Voice Mail:            yes
    Record&Play:           yes
    Text Room:             yes
```

## docker build `--build-arg`
`--build-arg` provides away to override some build runtime arguments. Have a look at the `Dockerfile` for the `ARG` arguments to override.

Example build with `rabbitmq`, `paho-mqtt`, `data-channels` enabled, and `boringssl` disabled:
```
$ docker build --build-arg JANUS_WITH_MQTT=1 --build-arg JANUS_WITH_RABBITMQ=1 --build-arg JANUS_WITH_DATACHANNELS=1 --build-arg JANUS_WITH_BORINGSSL=0 -t jemmic/docker-janus:latest .
```

