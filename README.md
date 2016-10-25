# docker-janus
`docker-janus` is a Debian 8 based docker image for [Meetecho's Janus Gateway](https://github.com/meetecho/janus-gateway)

## Description
All the janus docker builds I have seen in hub.docker.com were all ubuntu based and/or of some redhat flavor. I successfully build janus in debian 7 and 8 before, so I thought it would be a good way to practice docker best practices and provide a debian based image at the same time.

For the automated build go to [hub.docker.com](https://hub.docker.com/r/mcroth/docker-janus/)

You can use this image directly from [hub.docker.com](https://hub.docker.com/r/mcroth/docker-janus/) by issuing the following docker commands:
```
docker pull mcroth/docker-janus:latest
```

Many thanks for [meetecho](http://www.meetecho.com) for providing us [Janus Gateway](https://github.com/meetecho/janus-gateway)!

I have tried to build the image with docker best practices at hand. Should there be anything of note you notices, please do not hesitate to leave a comment!

## quickstart 
```
root@mcroth:~/sandbox# git clone https://github.com/krull/docker-janus.git
Cloning into 'docker-janus'...
remote: Counting objects: 51, done.
remote: Compressing objects: 100% (39/39), done.
remote: Total 51 (delta 12), reused 44 (delta 8), pack-reused 0
Unpacking objects: 100% (51/51), done.
Checking connectivity... done.
root@mcroth:~/sandbox# cd docker-janus/
root@mcroth:~/sandbox/docker-janus# docker-compose up -d
Creating network "janusdocker_front-tier" with driver "bridge"
Creating network "janusdocker_back-tier" with driver "bridge"
Pulling janus-gateway (mcroth/docker-janus:latest)...
latest: Pulling from mcroth/docker-janus
6a5a5368e0c2: Pull complete
c98cef4c208b: Pull complete
76dc1a643124: Pull complete
74cae242e22d: Pull complete
e299d71a0a74: Pull complete
19ef9eddff9c: Pull complete
bfa426fc5ba7: Pull complete
f2c856642d97: Pull complete
7074c35f0d15: Pull complete
724a1491bde8: Pull complete
618ceafccc5a: Pull complete
Digest: sha256:86f6921bb3cfdb52df25e4f4857660dd6a9abab69807cb2c2d5548756a4a1fab
Status: Downloaded newer image for mcroth/docker-janus:latest
Creating janus-gateway
root@mcroth:~/sandbox/docker-janus# docker ps -a
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                                            NAMES
63cd3bcf2a78        mcroth/docker-janus   "/opt/janus/bin/janus"   10 seconds ago      Up 8 seconds        0.0.0.0:8088->8088/tcp, 0.0.0.0:8188->8188/tcp   janus-gateway
root@mcroth:~/sandbox/docker-janus# 
```

A full set of default janus config files are in `./janus` folder. 

## build criteria
`janus-gateway` is built with the following configured options diabled, as I do not have the need for them to be enabled by default:
```
./configure --prefix=/opt/janus --enable-post-processing --disable-docs --disable-boringssl --disable-mqtt --disable-rabbitmq
```

##default build
There is a `Makefile`, with some directives on building janus. Have a look at that file and check the options. Issuing a `make` will run the default build with the options set below.

```
DataChannels support:      yes
BoringSSL (no OpenSSL):    no
Recordings post-processor: yes
TURN REST API client:      yes
Doxygen documentation:     no
Transports:
    REST (HTTP/HTTPS):     yes
    WebSockets:            yes (new API)
    RabbitMQ:              no
    MQTT:                  no
    Unix Sockets:          yes
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

##docker build `--build-arg`
`--build-arg` provides away to override some build runtime arguments. Have a look at the `Dockerfile` for the `ARG` arguments to override.

Example build with `rabbitmq`, `paho-mqtt`, `boringssl` enabled, and `data-channels` disabled:
```
root@mcroth:~/sandbox/docker-janus# docker build --build-arg JANUS_WITH_BORINGSSL=1 --build-arg JANUS_WITH_PAHOMQTT=1 --build-arg JANUS_WITH_RABBITMQ=1 --build-arg JANUS_WITH_DATACHANNELS=0 -t mcroth/docker-janus:latest .
```

