FROM debian:jessie
MAINTAINER brendan jocson <brendan@jocson.eu>

# bootstrap environment
ENV BUILD_SRC="/usr/local/src"
ENV CONFIG_PATH="/opt/janus/etc/janus"
ENV DOCKER_SH="/tmp/docker_sh"
ENV JANUS_RELEASE="v0.2.0"

ADD docker_sh/buildenv.sh $DOCKER_SH/
RUN $DOCKER_SH/buildenv.sh

ADD docker_sh/libsrtp.sh $DOCKER_SH/
RUN $DOCKER_SH/libsrtp.sh

ADD docker_sh/usrsctp.sh $DOCKER_SH/
RUN $DOCKER_SH/usrsctp.sh

ADD docker_sh/libwebsockets.sh $DOCKER_SH/
RUN $DOCKER_SH/libwebsockets.sh

ADD docker_sh/janus-gateway.sh $DOCKER_SH/
RUN $DOCKER_SH/janus-gateway.sh

CMD ["/opt/janus/bin/janus"]
