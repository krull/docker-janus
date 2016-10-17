TEMPLATE_NAME ?= mcroth/docker-janus

run: image
	docker run -ti -v $(CURDIR)/janus/etc/janus/:/opt/janus/etc/janus/ -v $(CURDIR)/janus/janus.log:/var/log/janus.log -p 0.0.0.0:8088:8088 -p 0.0.0.0:8188:8188 -t $(TEMPLATE_NAME)

daemon: image
	docker run -d -v $(CURDIR)/janus/etc/janus/:/opt/janus/etc/janus/ -v $(CURDIR)/janus/janus.log:/var/log/janus.log -p 0.0.0.0:8088:8088 -p 0.0.0.0:8188:8188 -t $(TEMPLATE_NAME)

shell: image
	docker run -v $(CURDIR)/janus/etc/janus/:/opt/janus/etc/janus/ -v $(CURDIR)/janus/janus.log:/var/log/janus.log -p 0.0.0.0:8088:8088 -p 0.0.0.0:8188:8188 -a stdin -a stdout -i -t $(TEMPLATE_NAME) /bin/bash

image:
	docker build -t $(TEMPLATE_NAME) .

stop:
	docker ps | grep janus | cut -f1 -d' ' | xargs docker stop
